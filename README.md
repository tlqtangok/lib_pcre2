# lib_pcre2
a integrated  cpp pcre2lib,  just like perl regex 


## set environment

```bash
:: in cmd.exe
.\vcpkg install pcre2:x64-windows && .\vcpkg integrate install 
:: then make sure have lib and includes

```
## to build 

```bash
:: in cmd.exe
bld.bat 

```

## build log 

```text
d:\jd\t\git\lib_pcre2>setlocal

d:\jd\t\git\lib_pcre2>where cl  1>nul 2>&1

d:\jd\t\git\lib_pcre2>if 0 NEQ 0 (
echo.
 echo Error: Microsoft C++ Build Tools not found in PATH.
 echo Please run this script from a "Developer Command Prompt for VS".
 echo.
 pause
 exit /b 1
)

d:\jd\t\git\lib_pcre2>pushd d:\jd\t\git\lib_pcre2\

d:\jd\t\git\lib_pcre2>set ROOT_DIR=d:\jd\t\git\lib_pcre2

d:\jd\t\git\lib_pcre2>set VCPKG_INCLUDE=d:\jd\t\git\lib_pcre2\lib\pcre2\include

d:\jd\t\git\lib_pcre2>set VCPKG_LIB=d:\jd\t\git\lib_pcre2\lib\pcre2\lib

d:\jd\t\git\lib_pcre2>echo Compiling...
Compiling...

d:\jd\t\git\lib_pcre2>cl /EHsc /W4 /std:c++11    /I"d:\jd\t\git\lib_pcre2\lib\pcre2\include"    /DPCRE2_STATIC    main.cpp regex.cpp    /link /LIBPATH:"d:\jd\t\git\lib_pcre2\lib\pcre2\lib" pcre2-8.lib
用于 x64 的 Microsoft (R) C/C++ 优化编译器 19.44.35217 版
版权所有(C) Microsoft Corporation。保留所有权利。

cl: 命令行 warning D9002 :忽略未知选项“/std:c++11”
main.cpp
regex.cpp
正在生成代码...
Microsoft (R) Incremental Linker Version 14.44.35217.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:main.exe
/LIBPATH:d:\jd\t\git\lib_pcre2\lib\pcre2\lib
pcre2-8.lib
main.obj
regex.obj

d:\jd\t\git\lib_pcre2>if 0 NEQ 0 (
echo Build failed!
 pause
 exit /b 1
)

d:\jd\t\git\lib_pcre2>echo.


d:\jd\t\git\lib_pcre2>echo Build successful! Output: main.exe
Build successful! Output: main.exe

d:\jd\t\git\lib_pcre2>pause

```

## run log

```text
d:\jd\t\git\lib_pcre2>.\main.exe
PCRE2 Version: 10.46 2025-08-27

=== Test 1: Basic Match ===
Match found!

=== Test 2: Capture Groups ===
Full match: user@example.com
Username: user
Domain: example.com

=== Test 3: Case Insensitive ===
Case insensitive match works!

=== Test 4: Simple Substitution ===
Before: abc123abc456
After:  XYZ123abc456

=== Test 5: Global Substitution ===
Before: abc123abc456abc
After:  XYZ123XYZ456XYZ

=== Test 6: Multiple Operations ===
Found price: $100
Updated: The price is $200

=== Test 7: Phone Formatting ===
Before: 1234567890
After:  (123) 456-7890

=== All tests completed ===



```


## interface 

### demo match

```cpp
        Regex text("Hello 123 World");
        
        if (text % m(R"(\d+)"))
        {
            std::cout << "Match found!" << std::endl;
        }
        else
        {
            std::cout << "No match" << std::endl; 
        }

```

### demo capture groups

```cpp
        Regex email("user@example.com");
        auto matcher = m(R"((\w+)@(\w+\.\w+))");
        
        if (email % matcher)
        {
            std::cout << "Full match: " << matcher[0] << std::endl;
            std::cout << "Username: " << matcher[1] << std::endl;
            std::cout << "Domain: " << matcher[2] << std::endl;
        }

```

### demo case insensitive match

```cpp
        Regex text("Hello World");
        
        if (text % m(R"(hello)", "i"))
        {
            std::cout << "Case insensitive match works!" << std::endl;
        }

```

### demo simple substitution

```cpp
        Regex text("abc123abc456");
        std::cout << "Before: " << text.str() << std::endl;
        
        text % s(R"(abc)", "XYZ");
        std::cout << "After:  " << text.str() << std::endl;

```


### demo global substitution

```cpp
        Regex text("abc123abc456abc");
        std::cout << "Before: " << text.str() << std::endl;
        
        text % s(R"(abc)", "XYZ", "g");
        std::cout << "After:  " << text.str() << std::endl;

```


### demo multiple operations

```cpp
        Regex text("The price is $100");
        
        if (text % m(R"(\$(\d+))"))
        {
            auto matcher = m(R"(\$(\d+))");
            // matcher(text.str());
            text % matcher;

            std::cout << "Found price: $" << matcher[1] << std::endl;
        }
        
        text % s(R"(\$\d+)", "$200");
        std::cout << "Updated: " << text.str() << std::endl;

```


### demo capture order

```cpp
        Regex phone("1234567890");
        auto phone_matcher = m(R"((\d{3})(\d{3})(\d{4}))");
        
        if (phone % phone_matcher)
        {
            std::cout << "Before: " << phone.str() << std::endl;
            
            phone % s(R"((\d{3})(\d{3})(\d{4}))", "($1) $2-$3");
            std::cout << "After:  " << phone.str() << std::endl;
        }

```
