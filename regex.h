#ifndef REGEX_H
#define REGEX_H

#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>
#include <string>
#include <vector>
#include <memory>
#include <stdexcept>

class Regex;
class RegexMatch;
class RegexSubst;

class RegexMatch
{
public:
    RegexMatch(const std::string& pattern, uint32_t options = 0);
    ~RegexMatch();
    
    bool operator()(const std::string& subject);
    
    std::string operator[](size_t index) const;
    size_t count() const;
    std::string matched() const;
    
    static std::string version();

private:
    void compile(const std::string& pattern, uint32_t options);
    
    pcre2_code* _regex;
    pcre2_match_data* _match_data;
    std::string _subject;
    int _match_result;
};

class RegexSubst
{
public:
    RegexSubst(const std::string& pattern, const std::string& replacement, bool global = false);
    ~RegexSubst();
    
    std::string operator()(const std::string& subject);
    int count() const;

private:
    void compile(const std::string& pattern);
    std::string expandReplacement(const std::string& subject, PCRE2_SIZE* ovector, int rc);
    
    pcre2_code* _regex;
    std::string _replacement;
    bool _global;
    int _subst_count;
};

class Regex
{
public:
    Regex(const std::string& text);
    
    bool operator%(const RegexMatch& matcher);
    std::string operator%(const RegexSubst& subst);
    
    operator std::string() const;
    std::string str() const;

private:
    std::string _text;
};

RegexMatch m(const std::string& pattern);
RegexMatch m(const std::string& pattern, const std::string& flags);

RegexSubst s(const std::string& pattern, const std::string& replacement);
RegexSubst s(const std::string& pattern, const std::string& replacement, const std::string& flags);

#endif