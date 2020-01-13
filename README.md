# python-installer
This codebase is for managing python distributions usin NSIS. It allows you to put together and deploy a python virtual environment, with locally sourced python wheels, so you can ensure that users are working in the same environment as you are. Furthermore, you can share your build without an internet connection, which makes deployment easier in certain situations.

Run myPython_Build to create an archive with the installer inside.
Modify myPython_Build to update your environment version, and then do pip freeze > package_list.txt
Necessary resources can be added to /resources
