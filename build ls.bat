v -cc msvc -m64 -os windows -gc boehm -g -showcc -o "bin\pls.exe" -path "@vlib|@vmodules|modules" "language server"
pause