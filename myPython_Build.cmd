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
SET VERSION=myPython_38100
:: -- ADMIN NOTES: Set Python Distribution Folder Name Here ie ...\Programs\Python\Python38\... = Python38
SET PYFOLDER=Python38

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
SET PATH=%LOCALAPPDATA%\Programs\Python\%PYFOLDER%;%LOCALAPPDATA%\Programs\Python\%PYFOLDER%\Scripts;%PATH%
python.exe -m pip install --upgrade pip
FOR /f "tokens=*" %%A IN (packages\package_list.txt) DO python.exe -m pip download --no-deps %%A -d packages\site-packages\

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
FOR /f "tokens=*" %%A IN ('dir /b myPython.exe') DO REN %%A %INSTNAME%%%~xA

:: Create User Installer Archive
IF EXIST %VERSION%.zip ( DEL %VERSION%.zip )
powershell -command "Compress-Archive -Path %INSTNAME%.exe -DestinationPath %VERSION%.zip -Update"
powershell -command "Compress-Archive -Path %CD%\packages\ -DestinationPath %VERSION%.zip -Update"
powershell -command "Compress-Archive -Path %CD%\resources\ -DestinationPath %VERSION%.zip -Update"

:: Clear Temporary Files

DEL %INSTNAME%.exe
DEL %INSTNAME%.cmd
DEL packages\package_list.txt
RD /S /Q %VERSION%\
