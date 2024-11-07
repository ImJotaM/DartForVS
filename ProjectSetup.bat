@echo off

if not exist dart-sdk (
    curl -L -O https://storage.googleapis.com/dart-archive/channels/stable/release/3.5.4/sdk/dartsdk-windows-x64-release.zip
    cls
    powershell -Command "Expand-Archive -Path 'dartsdk-windows-x64-release.zip' -DestinationPath '%CD%'"
    del /q /s dartsdk-windows-x64-release.zip
    cls
)

echo.

if not exist vscode (
    mkdir vscode
    echo {"dart.cliConsole": "externalTerminal"}>vscode\settings.json
)

set /p PROJECT_NAME=Insert your project name: 

set DART_SDK_DIR=dart-sdk
set DART_BIN_DIR=%DART_SDK_DIR%\bin
set DART_EXE=%DART_BIN_DIR%\dart.exe

set VSCODE_DIR=vscode
set RUNNER_DIR=Runner

%DART_EXE% create %PROJECT_NAME%

rmdir /q /s %PROJECT_NAME%\test
rmdir /q /s %PROJECT_NAME%\lib
rmdir /q /s %PROJECT_NAME%\bin

mkdir %PROJECT_NAME%\bin

echo void main(){}>%PROJECT_NAME%\bin\%PROJECT_NAME%.dart 

mkdir %PROJECT_NAME%\.vscode
xcopy %VSCODE_DIR% %PROJECT_NAME%\.vscode /E /I /H /Y

pause