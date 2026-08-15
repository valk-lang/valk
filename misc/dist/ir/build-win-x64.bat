@echo off
cd /d "%~dp0"
clang --target=x86_64-pc-windows-msvc -Wno-override-module -O3 valk-win-x64.ll libs\win-x64\valk-stack-swap.o -o valk-win-x64.exe -Xlinker "/stack:8388608,65536" -Xlinker /guard:ehcont -lkernel32 -lwsock32 -lws2_32 -lntdll
