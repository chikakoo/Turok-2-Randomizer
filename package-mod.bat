:: Creates a zip with all the kpf files the mode needs

@echo off
setlocal enabledelayedexpansion

set "allFolders=anims char defs gfx materials models particles scripts textures"

:: Create an output directory to work in
set "outputDir=output"
if not exist "%outputDir%" mkdir "%outputDir%"

:: Clean up from last time
del "%outputDir%\Turok2Mod.zip" >nul 2>&1

:: Zip all the files
for %%F in (%allFolders%) do (
    if exist "%%F" (
		echo Packaging %%F...
		7z a -tzip "%outputDir%\%%F.kpf" "%%F" >nul
	) else (
		echo Skipping %%F (not found)
	)
)

echo Creating final archive...
pushd "%outputDir%"
7z a -tzip "Turok2Mod.zip" "*.kpf" >nul
popd

:: Clean up the kpfs
del "%outputDir%\*.kpf" >nul 2>&1

echo Done!
pause