set VS_CL_OPT_NODEBUG=/c /ZI /nologo /W3 /WX- /diagnostics:column /sdl /O2 /Oi /D NDEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MDd /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive-  /external:W3 /Gd /TP /FC /errorReport:prompt

set VS_CL_OPT_DEBUG=/c /ZI /JMC /nologo /W3 /WX- /diagnostics:column /sdl /O2 /D DEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MDd /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive-  /external:W3 /Gd /TP /FC /errorReport:prompt


set VS_LIB_OPT=/NOLOGO /MACHINE:X64

set VS_LINK_OPT=/ERRORREPORT:PROMPT  /INCREMENTAL /MANIFEST  /manifest:embed /DEBUG /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE /NXCOMPAT /MACHINE:X64 /MANIFESTUAC:"level='asInvoker' uiAccess='false'"


set INC=..\..\pcre2\include


@echo off
where cl.exe 
if not %errorlevel% equ 0 (
    echo "- please setup your vs2022 environment"
    exit /b -1
)
@echo on



:: important : no /D DEF_DLL_EXPORTS in VS_CL_OPT !!!
CL.exe  %VS_CL_OPT_NODEBUG% /I"%INC%" *.cpp
lib.exe %VS_LIB_OPT% /OUT:"rex_8.lib"  *.obj ..\..\pcre2\lib\pcre2-8.lib

copy /Y rex_8.lib ..\..\pcre2\lib\
copy /Y rex.h ..\..\pcre2\include\

del rex_8.lib *.obj *.pdb *.idb


::CL.exe  %VS_CL_OPT_DEBUG% /I"%INC%" ..\src\test.cpp
::link.exe %VS_LINK_OPT% /implib:"slib.lib" /out:"mainapp.exe"  test.obj slib.lib 
::.\mainapp.exe
