:: create_libs.bat debug && create_libs.bat rel
@echo off
REM Build PCRE2 static library and executable
REM Usage: create_libs.bat [debug|release|rel]
REM Default: debug

REM Parse command line argument
set BUILD_TYPE=debug
if "%1"=="" goto :set_config
if /i "%1"=="debug" set BUILD_TYPE=debug
if /i "%1"=="release" set BUILD_TYPE=release
if /i "%1"=="rel" set BUILD_TYPE=release

:set_config
REM Define compiler options for both configurations
REM Debug: Minimal size while keeping debug symbols
set VS_CL_OPT_DEBUG=/c /Zi /nologo /W3 /sdl /Od /Gy /Gw /D DEBUG /D _CONSOLE /EHsc /MDd /Zc:inline /permissive- /TP
set VS_LIB_OPT_DEBUG=/NOLOGO /MACHINE:X64
set VS_LINK_OPT_DEBUG=/ERRORREPORT:PROMPT /INCREMENTAL /MANIFEST /manifest:embed /DEBUG /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE /NXCOMPAT /MACHINE:X64 /MANIFESTUAC:"level='asInvoker' uiAccess='false'"

REM Release: Maximum optimization for smallest size
::set VS_CL_OPT_RELEASE=/c /nologo /W3 /O1 /Oi /Gy /Gw /GL /GS- /D NDEBUG /D _CONSOLE /EHsc /MD /Zc:inline /permissive- /TP
set VS_CL_OPT_RELEASE=/c /Zi /nologo /W3 /sdl /Od /Gy /Gw /D NDEBUG /D _CONSOLE /EHsc /MD /Zc:inline /permissive- /TP
set VS_LIB_OPT_RELEASE=/NOLOGO /MACHINE:X64 /LTCG
set VS_LINK_OPT_RELEASE=/ERRORREPORT:PROMPT /INCREMENTAL /MANIFEST /manifest:embed /DEBUG /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE /NXCOMPAT /MACHINE:X64 /MANIFESTUAC:"level='asInvoker' uiAccess='false'"

REM Set active configuration
if "%BUILD_TYPE%"=="debug" (
    set VS_CL_OPT=%VS_CL_OPT_DEBUG%
    set VS_LIB_OPT=%VS_LIB_OPT_DEBUG%
    set VS_LINK_OPT=%VS_LINK_OPT_DEBUG%
    set CONFIG_NAME=Debug
) else (
    set VS_CL_OPT=%VS_CL_OPT_RELEASE%
    set VS_LIB_OPT=%VS_LIB_OPT_RELEASE%
    set VS_LINK_OPT=%VS_LINK_OPT_RELEASE%
    set CONFIG_NAME=Release
)

REM Check if Visual Studio environment is set up
where cl.exe >nul 2>&1
if not %errorlevel% equ 0 (
    echo ERROR: Please setup your VS2022 environment
    echo Run: "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    exit /b -1
)

pushd %~dp0
set ROOT_DIR=%CD%
set VCPKG_INCLUDE=%ROOT_DIR%\lib\pcre2\include
set VCPKG_LIB=%ROOT_DIR%\lib\pcre2\lib

echo ============================================
echo Building PCRE2 %CONFIG_NAME% Library
echo ============================================
echo.

REM Clean up old files
del *.obj *.exe *.pdb *.ilk 2>nul

echo Step 1: Building rex_8.lib [%CONFIG_NAME%]...
pushd %ROOT_DIR%\lib\pcre2\src
call bld_staticlib.bat %BUILD_TYPE%
popd

if not %errorlevel% equ 0 (
    echo ERROR: Failed to build rex_8.lib
    exit /b 1
)

echo.
echo Step 2: Compiling main.cpp [%CONFIG_NAME%]...
CL.exe %VS_CL_OPT% /I"%VCPKG_INCLUDE%" main.cpp

if not %errorlevel% equ 0 (
    echo ERROR: Failed to compile main.cpp
    exit /b 1
)

echo.
echo Step 3: Linking mainapp.exe...
link.exe %VS_LINK_OPT% /out:"mainapp.exe" main.obj %VCPKG_LIB%\rex_8.lib

if not %errorlevel% equ 0 (
    echo ERROR: Failed to link mainapp.exe
    exit /b 1
)

echo.
echo ============================================
echo SUCCESS! %CONFIG_NAME% Library and demo created
echo ============================================
echo.
echo Files created:
echo   - rex_8.lib (static library - %CONFIG_NAME%)
echo   - mainapp.exe (test program)
echo.
echo Running mainapp.exe...
echo.
.\mainapp.exe

echo.
echo.
echo To use in your projects:
echo   1. Copy rex_8.lib to your project
echo   2. Add include path: /I"%VCPKG_INCLUDE%"
echo   3. Link with: rex_8.lib
echo.

popd
