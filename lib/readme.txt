win11 + vs2022 

set vsproj as following:

======
      <AdditionalIncludeDirectories> $(SolutionDir)_3rd\dep;$(SolutionDir)_3rd\fmt\include;$(SolutionDir)_3rd\opencv3.4.16\build\include;$(SolutionDir)_3rd\pcre2\include </AdditionalIncludeDirectories>
      <AdditionalLibraryDirectories> $(SolutionDir)_3rd\fmt\lib;$(SolutionDir)_3rd\opencv3.4.16\build\x64\vc15\lib;$(SolutionDir)_3rd\pcre2\lib </AdditionalLibraryDirectories>
      <AdditionalDependencies> fmt_slib_10.1.0.lib;opencv_world3416d.lib;regex_8.lib;$(CoreLibraryDependencies);%(AdditionalDependencies) </AdditionalDependencies>
======
