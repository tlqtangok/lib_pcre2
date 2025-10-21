setlocal

where cl >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error: Microsoft C++ Build Tools not found in PATH.
    echo Please run this script from a "Developer Command Prompt for VS".
    echo.
    pause
    exit /b 1
)

pushd %~dp0
set ROOT_DIR=%CD%
set VCPKG_INCLUDE=%ROOT_DIR%\lib\pcre2\include
set VCPKG_LIB=%ROOT_DIR%\lib\pcre2\lib

echo Compiling...
cl /EHsc /W4 /std:c++11 ^
   /I"%VCPKG_INCLUDE%" ^
   /DPCRE2_STATIC ^
   main.cpp regex.cpp ^
   /link /LIBPATH:"%VCPKG_LIB%" pcre2-8.lib

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful! Output: main.exe
pause


:: del /Q *.obj  *.exe 
