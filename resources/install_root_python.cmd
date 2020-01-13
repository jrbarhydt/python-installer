@ECHO OFF
FOR /f "tokens=*" %%G IN ('dir /b %1\python\*.exe') DO %1\python\%%G