:: -- This is the myPython Installer --
::
:: It will create the virtual environment executable and download necessary wheels to packages\site-packages\
::
:: Programs Needed:
::		This code will automatically install NSIS, 7-Zip and Python. You can update the executables in the resource folder.
:: Python Packages:
:: 		You can choose which packages will be downloaded by modifying packages\package_list.txt
::
@ECHO off

:: -- ADMIN NOTES: Set myPython Version Name Here
SET VERSION=myPython_37600
:: -- ADMIN NOTES: Set Python Distribution Folder Name Here ie ...\Programs\Python\Python37\... = Python37
SET PYFOLDER=Python37

:: No need to modify anything below here.
::============================================================================================================

BREAK > packages\myPython.version
BREAK > packages\python.version
ECHO|SET /p versOut=%VERSION%>packages\myPython.version
ECHO|SET /p foldOut=%PYFOLDER%>packages\python.version

:: Install Python Distribution
IF EXIST %LOCALAPPDATA%\Programs\Python\%PYFOLDER%\python.exe (
    ECHO %PYFOLDER% Found
) ELSE (
    ECHO %PYFOLDER% Not Found, Installing...
	FOR /f "tokens=*" %%G IN ('dir /b resources\python\*.exe') DO resources\python\%%G
)

:: Install NSIS
IF EXIST "c:\Program Files (x86)\NSIS\Bin\makensis.exe" (
    ECHO NSIS Found
) ELSE (
    ECHO NSIS Not Found, Installing...
	FOR /f "tokens=*" %%G IN ('dir /b resources\nsis\nsis*.exe') DO resources\nsis\%%G
)

:: Download Python Wheels
COPY /y package_list.txt packages\package_list.txt
SET PATH=%PATH%;%LOCALAPPDATA%\Programs\Python\%PYFOLDER%;%LOCALAPPDATA%\Programs\Python\%PYFOLDER%\Scripts
python.exe -m pip install --upgrade pip
::FOR /f "tokens=*" %%A IN (packages\package_list.txt) DO python.exe -m pip download --no-deps %%A -d packages\site-packages\

:: Create Wheel List
BREAK > packages\wheel.list
FOR /f "tokens=*" %%A IN ('dir /b packages\site-packages\*.*') DO ECHO packages\site-packages\%%A >> packages\wheel.list

:: Setup VirtualEnv Packages
python.exe -m pip download --no-deps virtualenvwrapper-win -d packages\venv\
python.exe -m pip download --no-deps virtualenv -d packages\venv\
python.exe -m pip download --no-deps activate -d packages\venv\
BREAK > packages\venv.list
FOR /f "tokens=*" %%A IN ('dir /b packages\venv\*.*') DO ECHO packages\venv\%%A >> packages\venv.list

:: Create the myPython installer
"c:\Program Files (x86)\NSIS\Bin\makensis.exe" nsi_files\myPython_installer.nsi

:: Uncomment for verbose NSIS setup output
::PAUSE

:: Create myPython User Installer
SET INSTNAME=Install_%VERSION%
FOR /f "tokens=*" %%A IN ('dir /b myPython.exe') DO REN %%A %VERSION%%%~xA
BREAK > %INSTNAME%.cmd
ECHO @ECHO OFF>>%INSTNAME%.cmd
ECHO SET VERSION=%VERSION%>>%INSTNAME%.cmd
ECHO SET PYFOLDER=%PYFOLDER%>>%INSTNAME%.cmd
ECHO CD myInstall>>%INSTNAME%.cmd
ECHO IF EXIST %%LOCALAPPDATA%%\Programs\Python\%%PYFOLDER%%\python.exe ( ECHO %%PYFOLDER%% Found ) ELSE ( FOR /f "tokens=*" %%%%G IN ('dir /b resources\python\*.exe') DO resources\python\%%%%G)>>%INSTNAME%.cmd

ECHO ECHO Adding %%PYFOLDER%% to PATH...>>%INSTNAME%.cmd
ECHO powershell -command "[Environment]::SetEnvironmentVariable(\"PATH\", \"$env:LOCALAPPDATA\Programs\Python\%PYFOLDER%\Scripts\", \"User\")">>%INSTNAME%.cmd
ECHO ECHO Adding %%PYFOLDER%%\Scripts to PATH...>>%INSTNAME%.cmd
ECHO powershell -command "[Environment]::SetEnvironmentVariable(\"PATH\", \"$env:LOCALAPPDATA\Programs\Python\%PYFOLDER%\", \"User\")">>%INSTNAME%.cmd
ECHO ECHO Running %%VERSION%% Installer...
ECHO %%VERSION%%.exe>>Install_%VERSION%.cmd

:: Create User Installer Archive
IF EXIST %VERSION%.zip ( DEL %VERSION%.zip )
XCOPY /E /I /Y packages myInstall\packages\
XCOPY /E /I /Y resources myInstall\resources\
COPY /Y %VERSION%.exe myInstall\%VERSION%.exe
attrib +h myInstall
powershell -command "Compress-Archive -Path %CD%\myInstall\ -DestinationPath %VERSION%.zip"
powershell -command "Compress-Archive -Path %CD%\%INSTNAME%.cmd -DestinationPath %VERSION%.zip -Update"
attrib +h %VERSION%.zip\myInstall
pause
:: Clear Temporary Files
DEL %VERSION%.exe
DEL %INSTNAME%.cmd
DEL packages\package_list.txt
RD /S /Q myInstall\

:: Add result to PATH
powershell -command "[Environment]::SetEnvironmentVariable(\"PATH\", \"$env:C:\virtualenvs\%VERSION%\Scripts\", \"User\")"