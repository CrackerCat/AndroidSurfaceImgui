@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

SET "ARGV01=%~1"
SET "ARGV02=%~2"
SET "ARGV03=%~3"

@REM Initialize CMAKE_TOOLCHAIN_FILE
IF NOT DEFINED NDK_PATH (
    SET NDK_PATH=%ARGV01%
) ELSE IF DEFINED ARGV01 (
    SET NDK_PATH=%ARGV01%
)
IF NOT DEFINED NDK_PATH (
    SET NDK_PATH=C:/Softwares/Android/NDK/android-ndk-r25c
)
SET CMAKE_TOOLCHAIN_FILE=%NDK_PATH%/build/cmake/android.toolchain.cmake
IF NOT EXIST %CMAKE_TOOLCHAIN_FILE% (
    ECHO [-] CMAKE_TOOLCHAIN_FILE %CMAKE_TOOLCHAIN_FILE% does not exist
    EXIT
)

@REM Initialize ANDROID_PLATFORM
SET MINSDKVERSION=%ARGV02%
IF DEFINED MINSDKVERSION (
    SET ANDROID_PLATFORM=android-%MINSDKVERSION%
) ELSE (
    SET ANDROID_PLATFORM=android-21
)

@REM Initialize ANDROID_ABIS
SET ANDROID_ABIS=armeabi-v7a arm64-v8a x86 x86_64

@REM Check cmake tools
WHERE /Q cmake
SET IS_CMAKE_EXIST=%ERRORLEVEL%
SET CMAKE_TOOLS=cmake
IF DEFINED ARGV03 (
    SET CMAKE_TOOLS=%ARGV03%/bin/cmake.exe
) ELSE IF %IS_CMAKE_EXIST% == 1 (
    SET CMAKE_TOOLS=C:/Softwares/CMake/bin/cmake.exe
)
IF NOT %CMAKE_TOOLS% == cmake (
    IF NOT EXIST %CMAKE_TOOLS%  (
        ECHO [-] CMAKE_TOOLS %CMAKE_TOOLS% does not exist
        EXIT
    )
)

@REM Echo environment
ECHO [=] CMAKE_TOOLCHAIN_FILE %CMAKE_TOOLCHAIN_FILE%
ECHO [=] ANDROID_PLATFORM %ANDROID_PLATFORM%
ECHO [=] ANDROID_ABIS %ANDROID_ABIS%
ECHO [=] CMAKE_TOOLS %CMAKE_TOOLS%

@REM Build
FOR %%A IN (%ANDROID_ABIS%) DO (
    ECHO [*] Configuration %%A...
    ECHO [=] Execute command %CMAKE_TOOLS% -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=%CMAKE_TOOLCHAIN_FILE% -DANDROID_PLATFORM=%ANDROID_PLATFORM% -DANDROID_ABI=%%A -S . -B build -G Ninja
    %CMAKE_TOOLS% -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=%CMAKE_TOOLCHAIN_FILE% -DANDROID_PLATFORM=%ANDROID_PLATFORM% -DANDROID_ABI=%%A -S . -B build -G Ninja
    ECHO [+] Done.

    ECHO [*] Build %%A...
    ECHO [=] Execute command %CMAKE_TOOLS% --build build --config Release
    %CMAKE_TOOLS% --build build --config Release
    ECHO [+] Done.
)

ECHO All libraries build successfully.

ENDLOCAL