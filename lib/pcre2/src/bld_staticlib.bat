@echo off
:: Build static library
cl /c /W4 /I"..\..\pcre2\include" /DPCRE2_STATIC /EHsc regex.cpp
lib /OUT:regex_8.lib regex.obj

copy /Y regex_8.lib ..\..\pcre2\lib\
copy /Y regex.h ..\..\pcre2\include\

del regex_8.lib *.obj




if 0 == 1 (
# Build DLL
cl /LD /W4 /I"d:\jd\t\git\lib_pcre2\lib\pcre2\include" /DPCRE2_STATIC /DREGEX_EXPORTS /EHsc regex.cpp /link /LIBPATH:"d:\jd\t\git\lib_pcre2\lib\pcre2\lib" pcre2-8.lib /OUT:regex.dll

# Use static library
cl /W4 /I"d:\jd\t\git\lib_pcre2\lib\pcre2\include" /DPCRE2_STATIC /EHsc main.cpp regex.lib /link /LIBPATH:"d:\jd\t\git\lib_pcre2\lib\pcre2\lib" pcre2-8.lib


# Step 1: Rebuild regex.lib without PCRE2_STATIC
cl /c /W4 /I"d:\jd\t\git\lib_pcre2\lib\pcre2\include" /EHsc regex.cpp
lib /OUT:regex.lib regex.obj

# Step 2: Link with dynamic PCRE2
cl /W4 /I"d:\jd\t\git\lib_pcre2\lib\pcre2\include" /EHsc main.cpp regex.lib /link /LIBPATH:"d:\jd\t\git\lib_pcre2\lib\pcre2\lib" pcre2-8.lib
)

@echo on 
