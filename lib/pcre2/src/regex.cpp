#include "regex.h"
#include <cstring>

RegexMatch::RegexMatch(const std::string& pattern, uint32_t options)
    : _regex(nullptr), _match_data(nullptr), _match_result(-1)
{
    compile(pattern, options);
}

RegexMatch::~RegexMatch()
{
    if (_match_data)
    {
        pcre2_match_data_free(_match_data);
    }
    if (_regex)
    {
        pcre2_code_free(_regex);
    }
}

void RegexMatch::compile(const std::string& pattern, uint32_t options)
{
    int errorcode;
    PCRE2_SIZE erroroffset;
    
    _regex = pcre2_compile(
        reinterpret_cast<PCRE2_SPTR>(pattern.c_str()),
        PCRE2_ZERO_TERMINATED,
        options,
        &errorcode,
        &erroroffset,
        nullptr
    );
    
    if (_regex == nullptr)
    {
        PCRE2_UCHAR buffer[256];
        pcre2_get_error_message(errorcode, buffer, sizeof(buffer));
        throw std::runtime_error(
            std::string("Regex compile failed at ") + 
            std::to_string(erroroffset) + ": " + 
            reinterpret_cast<char*>(buffer)
        );
    }
    
    _match_data = pcre2_match_data_create_from_pattern(_regex, nullptr);
}

bool RegexMatch::operator()(const std::string& subject)
{
    _subject = subject;
    _match_result = pcre2_match(
        _regex,
        reinterpret_cast<PCRE2_SPTR>(_subject.c_str()),
        _subject.length(),
        0,
        0,
        _match_data,
        nullptr
    );
    
    return _match_result >= 0;
}

std::string RegexMatch::operator[](size_t index) const
{
    if (_match_result < 0 || static_cast<int>(index) >= _match_result)
    {
        return "";
    }
    
    PCRE2_SIZE* ovector = pcre2_get_ovector_pointer(_match_data);
    size_t start = ovector[2 * index];
    size_t length = ovector[2 * index + 1] - ovector[2 * index];
    
    return _subject.substr(start, length);
}

size_t RegexMatch::count() const
{
    return _match_result > 0 ? _match_result : 0;
}

std::string RegexMatch::matched() const
{
    return operator[](0);
}

std::string RegexMatch::version()
{
    char version[64];
    pcre2_config(PCRE2_CONFIG_VERSION, version);
    return std::string(version);
}

RegexSubst::RegexSubst(const std::string& pattern, const std::string& replacement, bool global)
    : _regex(nullptr), _replacement(replacement), _global(global), _subst_count(0)
{
    compile(pattern);
}

RegexSubst::~RegexSubst()
{
    if (_regex)
    {
        pcre2_code_free(_regex);
    }
}

void RegexSubst::compile(const std::string& pattern)
{
    int errorcode;
    PCRE2_SIZE erroroffset;
    
    _regex = pcre2_compile(
        reinterpret_cast<PCRE2_SPTR>(pattern.c_str()),
        PCRE2_ZERO_TERMINATED,
        0,
        &errorcode,
        &erroroffset,
        nullptr
    );
    
    if (_regex == nullptr)
    {
        PCRE2_UCHAR buffer[256];
        pcre2_get_error_message(errorcode, buffer, sizeof(buffer));
        throw std::runtime_error(
            std::string("Regex compile failed: ") + 
            reinterpret_cast<char*>(buffer)
        );
    }
}

std::string RegexSubst::expandReplacement(const std::string& subject, PCRE2_SIZE* ovector, int rc)
{
    std::string result = _replacement;
    
    for (int i = rc - 1; i >= 0; i--)
    {
        std::string placeholder = "$" + std::to_string(i);
        size_t pos = 0;
        
        while ((pos = result.find(placeholder, pos)) != std::string::npos)
        {
            size_t start = ovector[2 * i];
            size_t length = ovector[2 * i + 1] - ovector[2 * i];
            std::string capture = subject.substr(start, length);
            
            result.replace(pos, placeholder.length(), capture);
            pos += capture.length();
        }
    }
    
    return result;
}

std::string RegexSubst::operator()(const std::string& subject)
{
    _subst_count = 0;
    std::string result = subject;
    pcre2_match_data* match_data = pcre2_match_data_create_from_pattern(_regex, nullptr);
    
    size_t offset = 0;
    
    do
    {
        int rc = pcre2_match(
            _regex,
            reinterpret_cast<PCRE2_SPTR>(result.c_str()),
            result.length(),
            offset,
            0,
            match_data,
            nullptr
        );
        
        if (rc < 0)
        {
            break;
        }
        
        PCRE2_SIZE* ovector = pcre2_get_ovector_pointer(match_data);
        size_t start = ovector[0];
        size_t end = ovector[1];
        
        std::string expanded = expandReplacement(result, ovector, rc);
        
        result = result.substr(0, start) + expanded + result.substr(end);
        _subst_count++;
        
        offset = start + expanded.length();
        
        if (!_global || offset >= result.length())
        {
            break;
        }
    }
    while (true);
    
    pcre2_match_data_free(match_data);
    return result;
}

int RegexSubst::count() const
{
    return _subst_count;
}

Regex::Regex(const std::string& text)
    : _text(text)
{
}

bool Regex::operator%(const RegexMatch& matcher)
{
    return const_cast<RegexMatch&>(matcher)(_text);
}

std::string Regex::operator%(const RegexSubst& subst)
{
    _text = const_cast<RegexSubst&>(subst)(_text);
    return _text;
}

Regex::operator std::string() const
{
    return _text;
}

std::string Regex::str() const
{
    return _text;
}

static uint32_t parseFlags(const std::string& flags)
{
    uint32_t options = 0;
    for (char c : flags)
    {
        switch (c)
        {
            case 'i': options |= PCRE2_CASELESS; break;
            case 'm': options |= PCRE2_MULTILINE; break;
            case 's': options |= PCRE2_DOTALL; break;
            case 'x': options |= PCRE2_EXTENDED; break;
        }
    }
    return options;
}

RegexMatch m(const std::string& pattern)
{
    return RegexMatch(pattern);
}

RegexMatch m(const std::string& pattern, const std::string& flags)
{
    return RegexMatch(pattern, parseFlags(flags));
}

RegexSubst s(const std::string& pattern, const std::string& replacement)
{
    return RegexSubst(pattern, replacement, false);
}

RegexSubst s(const std::string& pattern, const std::string& replacement, const std::string& flags)
{
    bool global = flags.find('g') != std::string::npos;
    return RegexSubst(pattern, replacement, global);
}