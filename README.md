# wimbuilder
a tiny framework which for editing the wim file(mostly for making Windows PE)


##What's me?
Based on the BAT batch file and the VBS script, use the system Dism command to update the WIM file.
Can be a key to generate a custom PE, or streamlining, modify the Windows 7 or above system installation image (install.wim)

just put definition files will `ADD FOLDERs/FILEs` `DELETE FOLDERs/FILES` `UPDATE REGISTY` to the wim file.

##This framework's features:
* SMALL and VERY SMALL, the script is less than 15KB with compression.
* The use of native support BAT, VBS script and the system comes with the command to support the mainstream Windows platform and the corresponding PE production.
    * of cause you can extend with ruby, python, autoit what any script if you installed them on your machine.
* Build platforms: Windows 7, Windows 8, Windows 8.1, Windows 10 (x86, x64)
* Build PE versions: WinPE 3.x, WinPE 4.0, WinPE 5.0, WinPE 5.1, Windows 10 PE (x86, x64)
* Build Windows versions: Windows 7, Windows 8, Windows 8.1, Windows 10 (x86, x64)
* The script is completely free. Without any form of encryption, anyone can copy, modify, re-publish, without any restrictions.
* Original i18n script component, support multiple languages.
* Simply place the file, define the file list, do not need any programming skills to facilitate the construction of their own PE.
* Each patch is a separate folder for the re-use, add functions to modify the independent and clear, can also be published to reduce the volume of updates released.
* Build the project No matter who machine, any platform can always generate the same from the boot.wim PE, and modify the reversible traceability.
* Just press the space to continue, you can quickly build a personalized start PE. (Up to 1 minute)
* Can be just press a key to build their own PE / Windows system.



##How to Use?
###STEP.1 Preparing the build environment (need just for the first time and it's easy to do)
**A**.Unzip the attachment to the root directory of the local disk drive(like D:), and get the following structure (only the files or directories that need attention)

```
-PB_Workspace\
  + Mnt\
    + Build\
      + ISO\
  + Projects\
  + WIM_Builder\
    + Config.ini
```

**B**. Copy the system ISO boot directory, bootmgr file to mnt \build\ISO, and create an empty sources directory.
  (The above is the default boot CD template, can be modified according to their own circumstances)

###STEP.2 Configure the parameters in the config.ini file to define the initial settings for all projects (settings can be overridden by the config.ini settings for each project).
* Mount directory (required)
* Install.wim for copying the original system files
* Building PE based WIM (boot.wim or own / others do wim)
* Mount image's index number (default is 1)
* output path (required)
* If need to access the full access to the file (use the system boot.wim need to be set to 0, it may take 2 to 5 minutes)
* If need full access to the registry
* etc.

###STEP.3 Projects directory to create a project directory, which stored a variety of Patch (* follow-up example shows)

###STEP.4 Double-click WIM_Builder\PE_Builder.bat, choose to build the project, no abnormal way to output a wim format PE.

###STEP.5 Double-click WIM_Builder\MakeBootISO.bat, wait a few seconds to get the start of the self-PE PE file.

On the STEP 3 can be downloaded for reference Mini10PE attachment.
The following explains the structure of ***Patch***.

**Patch for a directory, is a kind of streamlining, or a function update, the structure is as follows:**

```
Patch_Sample \
  + INIT.bat
  + KEEP_ITEMS.txt
  + DEL_DIRS.txt
  + DEL_FILES.txt
  + ADD_ITEMS.txt
  + X\ 
  + *.Reg
  + LAST.bat
```


* `INIT.bat`

  optional file, before the application of the patch, the initial custom script (to generate a list of files to add or modify, or other COPY operations, etc.)

* `KEEP_ITEMS.txt`

 optional file, the definition of a directory need to retain the file, the remaining files will be deleted

* `DEL_DIRS.txt`

  optional file, the directory to be deleted is defined, for example: Windows\SysWOW64

* `DEL_FILES.txt`

  optional file, define the file to be deleted, for example: Windows\System32\app.exe

* `ADD_ITEMS.txt`

  optional file, define a list of files or folders that need to be copied from the install.wim file
  
* `X\`

  optional folder, X folder, place the need to copy/update files in the PE, for example: X:\Windows\System32\XShell.exe

* `*.Reg`

  optional files, can be imported by default to the PE system registry file (the registry does not need to modify the project path for the PE_SOFT after the mount and so on, please keep the PE under the registry key name)
  
* `LAST.bat`

  optional file, custom scripts for additional processing needed for finalization (other than the above registry fix, such as dynamic creation of shortcuts, etc.)


***Note 1: The first line of the KEEP_ITEMS.txt file is the path of the folder that needs to be retained, and must be followed by "\" at the end. The following is a subdirectory or subfile that needs to be retained.***

***Note 2: The various catalogs under the project directory in alphabetical order. If a file is copied to System32, if a Patch is in the form of KEEP_ITEMS.txt, it may be deleted again.***

```
The solution is to change the order in which patches are applied, for example, A_TEST, B_TEST2, or 0_Patch1,1_Patch2. Use LAST.bat custom application of the order, will have the order of the Patch into any subdirectory (Package),
  Writing in LAST.bat:
    Call PB_APPLY_PATCH% ~ dp0Package\PatchB
    Call PB_APPLY_PATCH% ~ dp0Package\PatchA
  Note Patch name should not be set to X, because the Package directory is actually a Patch when dealing with, but the use of X directory other than the directory does not have any mechanism to achieve the purpose of custom patch order of purpose.
```
