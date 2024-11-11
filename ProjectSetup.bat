@echo off
setlocal enabledelayedexpansion


@REM ::Actual directory
set CURR_DIR=%CD%
@REM ::Actual directory with '\\' instead '\'
set CURR_DIR=!CURR_DIR:\=\\!

@REM ::'dart-sdk' path
set DART_SDK_DIR=dart-sdk
@REM ::'dart.exe' executable path
set DART_EXE=%DART_SDK_DIR%\bin\dart.exe


@REM ::Check dependencies(

    :Validate_Archives

    @REM ::Check 'dart-sdk'(

        set /p ="Searching for 'dart-sdk'... | " <nul

        if not exist %DART_SDK_DIR% (

            echo 'dart-sdk' Not found.

            @REM ::Downloading 'dart-sdk.zip'(

                echo Installing 'dartsdk-windows-x64-release.zip'...
                echo.
                curl -# -L -O https://storage.googleapis.com/dart-archive/channels/stable/release/3.5.4/sdk/dartsdk-windows-x64-release.zip
                cls

            @REM ::)

            @REM ::Extracting 'dart.zip'(

                echo Extracting 'dartsdk-windows-x64-release.zip'...
                echo.
                powershell -Command "Expand-Archive -Path 'dartsdk-windows-x64-release.zip' -DestinationPath '%CD%'"
                cls

            @REM ::)

            @REM ::Removing 'dart.zip'(

                echo Removing 'dartsdk-windows-x64-release.zip'...
                del /q /s dartsdk-windows-x64-release.zip > nul
                cls

            @REM ::)
            
            @REM ::Check archives again
            goto Validate_Archives

        ) else (

            @REM ::Dart-sdk is ok
            echo 'dart-sdk' Found.

        )

    @REM ::)

@REM ::)

echo.

@REM ::Input for project name
set /p PROJECT_NAME="Insert your project name: "
echo.

@REM ::Convert project name to lowercase(

    set _UCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ
    set _LCASE=abcdefghijklmnopqrstuvwxyz

    for /l %%a in (0,1,25) do (
        call set _FROM=%%_UCASE:~%%a,1%%
        call set _TO=%%_LCASE:~%%a,1%%
        call set PROJECT_NAME=%%PROJECT_NAME:!_FROM!=!_TO!%%
    )

@REM ::)


@REM ::Project path
set PROJECT_DIR=projects\%PROJECT_NAME%

@REM ::.vscode path
set VSCODE_DIR=%PROJECT_DIR%\.vscode


@REM ::Create folder 'projects' if it doesnt exist(

    set /p ="Searching for 'projects' folder... | " <nul

    if not exist projects (
        
        echo 'projects' not found.

        set /p ="Creating 'projects' folder... | " <nul
        mkdir projects
        echo 'projects' Created.

    ) else (

        echo 'projects' Found.

    )

@REM ::)

@REM ::Creating project using 'dart create'(

    set /p ="Creating project '%PROJECT_NAME%'... | " <nul

    %DART_EXE% create %PROJECT_DIR% > nul

    echo Projectd created.

@REM ::)

@REM ::Configuring project(

    set /p ="Configuring project '%PROJECT_NAME%'... | " <nul

    @REM ::Removing directories(

        rmdir /q /s %PROJECT_DIR%\test
        rmdir /q /s %PROJECT_DIR%\lib
        rmdir /q /s %PROJECT_DIR%\bin

    @REM ::)

    @REM ::Deleting useless files(

        del /q /s %PROJECT_DIR%\README.md > nul
        del /q /s %PROJECT_DIR%\CHANGELOG.md > nul
        del /q /s %PROJECT_DIR%\pubspec.lock > nul
        del /q /s %PROJECT_DIR%\.gitignore > nul

    @REM ::) 

    @REM ::Creating 'bin' directory
    mkdir %PROJECT_DIR%\bin

    @REM ::'PROJECT_NAME'.dart(

        echo void main() {>> %PROJECT_DIR%\bin\%PROJECT_NAME%.dart
        echo     print('Hello, Dart!');>> %PROJECT_DIR%\bin\%PROJECT_NAME%.dart
        echo }>> %PROJECT_DIR%\bin\%PROJECT_NAME%.dart

    @REM ::)

    echo Project configured.

@REM ::)

echo.

@REM ::VS Code files creation(

    echo Configuring VS Code...

    echo.

    @REM ::.vscode folder(

        set /p ="Creating folder '.vscode'... | " <nul
        mkdir %VSCODE_DIR%
        echo Folder created.

    @REM ::)

    @REM ::settings.json(

        set /p ="Creating file 'settings.json'... | " <nul
        echo {>> %VSCODE_DIR%\settings.json
        echo    "dart.cliConsole": "externalTerminal",>> %VSCODE_DIR%\settings.json
        echo    "dart.sdkPath": "%CURR_DIR%\\%DART_SDK_DIR%">> %VSCODE_DIR%\settings.json
        echo }>> %VSCODE_DIR%\settings.json
        echo File created.

    @REM ::)

    @REM ::extensions.json(

        set /p ="Creating file 'extensions.json'... | " <nul
        echo {>> %VSCODE_DIR%\extensions.json
        echo    "recommendations": [>> %VSCODE_DIR%\extensions.json
        echo        "Dart-Code.dart-code">> %VSCODE_DIR%\extensions.json
        echo    ]>> %VSCODE_DIR%\extensions.json
        echo }>> %VSCODE_DIR%\extensions.json
        echo File created.

    @REM ::)

    set /p ="Creating file 'OpenProject.bat'... | " <nul
    echo @echo off >> %PROJECT_DIR%\OpenProject.bat
    echo code .\>> %PROJECT_DIR%\OpenProject.bat
    echo File created.

    @REM ::installing dart extension(

        set /p ="Installing Dart extension... | " <nul

        set EXTENSION_INSTALLED=

        @REM ::Checks if the extension is already installed(
            for /f "delims=" %%e in ('code --list-extensions') do (
                if /I "%%e"=="Dart-code.dart-code" (
                    set EXTENSION_INSTALLED=1
                )
            )
        @REM ::)

        @REM ::If the extension is not installed it will be installed(
            
            if not defined EXTENSION_INSTALLED (
                
                powershell -Command "Start-Process 'code' -ArgumentList '--install-extension Dart-Code.dart-code' -NoNewWindow -Wait" > nul
                echo Extension installed.

            ) else (
                
                echo Already installed.

            )

        @REM ::)

    @REM ::)

    echo.

    echo VS Code configured succesfully.

@REM ::)

echo.

:Open_Question

@REM ::Asks if the user wants to open the project now
set /p OPEN_PROJECT=Do you want to open your project in VS Code? [Y/N]: 

@REM ::Uses user answer to do an action(
    
    if /I "!OPEN_PROJECT!"=="Y" (

        code %PROJECT_DIR%
        exit

    ) else if /I "!OPEN_PROJECT!"=="N" (
        
        exit

    ) else (
        
        echo Invalid answer.
        echo.
        goto Open_Question

    )
    
@REM ::)

pause