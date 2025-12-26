setlocal

::set VS_CL_OPT_NODEBUG=/c /ZI /nologo /W3 /WX- /diagnostics:column /sdl /O2 /Oi /D NDEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MDd /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive-  /external:W3 /Gd /TP /FC /errorReport:prompt
set VS_CL_OPT_NODEBUG=/c /ZI /nologo /W3 /WX- /diagnostics:column /sdl /O2 /Oi /D NDEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MD  /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive-  /external:W3 /Gd /TP /FC /errorReport:prompt

set VS_CL_OPT_DEBUG=/c /ZI /JMC /nologo /W3 /WX- /diagnostics:column /sdl /O2 /D DEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MDd /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive-  /external:W3 /Gd /TP /FC /errorReport:prompt


set VS_LIB_OPT=/NOLOGO /MACHINE:X64

set VS_LINK_OPT=/ERRORREPORT:PROMPT  /INCREMENTAL /MANIFEST  /manifest:embed /DEBUG /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE /NXCOMPAT /MACHINE:X64 /MANIFESTUAC:"level='asInvoker' uiAccess='false'"


::set INC=..\..\pcre2\include

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

echo build rex_8.lib 

pushd %ROOT_DIR%\lib\pcre2\src
call bld_staticlib.bat
popd 




echo Compiling...
CL.exe  %VS_CL_OPT_NODEBUG% /I"%VCPKG_INCLUDE%" main.cpp
link.exe %VS_LINK_OPT% /implib:"rex_8.lib" /out:"mainapp.exe"  main.obj %VCPKG_LIB%\rex_8.lib

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful! Output: mainapp.exe
pause


:: del /Q *.obj  *.exe 
