@echo off
setlocal enabledelayedexpansion

set CURR_DIR=%CD%
set CURR_DIR=!CURR_DIR:\=\\!

set DART_SDK_DIR=dart-sdk
set DART_BIN_DIR=%DART_SDK_DIR%\bin
set DART_EXE=%DART_BIN_DIR%\dart.exe

set VSCODE_DIR=vscode

:Validate_Archives
set /p ="Searching for 'dart-sdk'... " <nul

if not exist "%DART_SDK_DIR%" (
    echo Dart SDK not found.
    echo Installing 'dartsdk-windows-x64-release.zip'...
    echo.
    curl -# -L -O https://storage.googleapis.com/dart-archive/channels/stable/release/3.5.4/sdk/dartsdk-windows-x64-release.zip
    cls

    echo Extracting 'dartsdk-windows-x64-release.zip'...
    echo.
    powershell -Command "Expand-Archive -Path 'dartsdk-windows-x64-release.zip' -DestinationPath '%CD%'"
    cls

    echo Removing 'dartsdk-windows-x64-release.zip'...
    del /q /s dartsdk-windows-x64-release.zip > nul
    cls

    goto Validate_Archives

) else (
    echo Dart SDK Found.
)

set /p ="Searching for 'vscode'... " <nul

if not exist "%VSCODE_DIR%" (
    echo VSCode folder not found.
    echo Creating folder 'vscode'...
    mkdir "%VSCODE_DIR%"
    
    echo Creating 'settings.json'...
    echo {>> "%VSCODE_DIR%\settings.json"
    echo    "dart.cliConsole": "externalTerminal",>> "%VSCODE_DIR%\settings.json"
    echo    "dart.sdkPath": "%CURR_DIR%\\%DART_SDK_DIR%">> "%VSCODE_DIR%\settings.json"
    echo }>> "%VSCODE_DIR%\settings.json"

    echo Creating 'extensions.json'
    echo {>> "%VSCODE_DIR%\extensions.json"
    echo    "recommendations": [>> "%VSCODE_DIR%\extensions.json"
    echo        "Dart-Code.dart-code">> "%VSCODE_DIR%\extensions.json"
    echo    ]>> "%VSCODE_DIR%\extensions.json"
    echo }>> "%VSCODE_DIR%\extensions.json"

    cls

    goto Validate_Archives

) else (
    echo VSCode Folder Found.
)

echo.
set /p PROJECT_NAME=Insert your project name: 

if not exist "projects" (
    mkdir "projects"
)

set PROJECT_DIR="projects\%PROJECT_NAME%"

echo.
echo Creating project '%PROJECT_NAME%'...
%DART_EXE% create "%PROJECT_DIR%" > nul

echo Project '%PROJECT_NAME%' created.

echo.

echo Configuring project '%PROJECT_NAME%'...
rmdir /q /s "%PROJECT_DIR%\test"
rmdir /q /s "%PROJECT_DIR%\lib"
rmdir /q /s "%PROJECT_DIR%\bin"

del /q /s "%PROJECT_DIR%\README.md" > nul
del /q /s "%PROJECT_DIR%\CHANGELOG.md" > nul
del /q /s "%PROJECT_DIR%\pubspec.lock" > nul
del /q /s "%PROJECT_DIR%\.gitignore" > nul

mkdir "%PROJECT_DIR%\bin"

echo void main() {>> "%PROJECT_DIR%\bin\%PROJECT_NAME%.dart"
echo     print('Hello, Dart!');>> "%PROJECT_DIR%\bin\%PROJECT_NAME%.dart"
echo }>> "%PROJECT_DIR%\bin\%PROJECT_NAME%.dart"

mkdir "%PROJECT_DIR%\.vscode"
xcopy "%VSCODE_DIR%" "%PROJECT_DIR%\.vscode" /E /I /H /Y > nul

echo Project '%PROJECT_NAME%' configured.

echo.

:Open_Question

set /p OPEN_PROJECT=Do you want to open your project in VS Code? [Y/N]: 

if /I "!OPEN_PROJECT!"=="Y" (
    code "%PROJECT_DIR%"
    exit
) else if /I "!OPEN_PROJECT!"=="N" (
    exit
) else (
    echo Invalid answer.
    echo.
    goto Open_Question
)

pause