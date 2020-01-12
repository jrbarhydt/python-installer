::SET PYFOLDER=Python37
::SET VERSION=myPython_37600
::python.exe -m pip download --no-deps virtualenvwrapper-win -d packages\venv\
::python.exe -m pip download --no-deps virtualenv -d packages\venv\
::BREAK > packages\wheel.list
::FOR /f "tokens=*" %%A IN ('dir /b packages\venv\*.*') DO ECHO packages\venv\%%A >> packages\venv.list

::SET VERSION=myPython_37600
::FOR /f "tokens=*" %%A IN ('dir /b optoPython.exe') DO REN %%A %VERSION%%%~xA


SET VERSION=myPython_37600
SET PYFOLDER=Python37
SET INSTNAME=Install_%VERSION%

DEL %INSTNAME%.cmd
PAUSE



