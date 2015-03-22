@echo off
setlocal
setlocal ENABLEDELAYEDEXPANSION

@rem must have leading and trailing space
set alltargets= embedded zx 

if "%1" == "" (
   echo.
   echo WINMAKE: GENERATE Z80 LIBRARIES
   echo Usage: Winmake target
   echo.
   echo target=
   echo   all

   for %%t in (%alltargets%) do echo   %%t
   
   echo.
   exit /b
)

if "%1" == "all" (
   set targets=%alltargets%
) else (
   set targets=%*
)

echo.
echo WINMAKE: GENERATING Z80 LIBRARIES

for %%t in (%targets%) do (

   set temp=!alltargets: %%t =!

   if not "!temp!" == "%alltargets%" (
   
      echo.
      echo target = %%t
   
      copy /Y target\%%t\clib_cfg.asm . 1> nul
      copy /Y target\%%t\clib_target_cfg.asm . 1> nul

      echo   %%t_asm.lib
   
      z80asm -d -ns -nm -Mo -x%%t_asm @target/%%t/library/%%t_asm.lst
      move /Y %%t_asm.lib lib

      del /S *.o > nul 2>&1
      del /S *.err > nul 2>&1

      echo   %%t_sccz80.lib

      z80asm -d -ns -nm -Mo -x%%t_sccz80 @target/%%t/library/%%t_sccz80.lst
      move /Y %%t_sccz80.lib lib

      del /S *.o > nul 2>&1
      del /S *.err > nul 2>&1

      echo   %%t_sdcc_ix.lib

      z80asm -d -ns -nm -Mo -x%%t_sdcc_ix -D__SDCC -D__SDCC_IX @target/%%t/library/%%t_sdcc_ix.lst
      move /Y %%t_sdcc_ix.lib lib

      del /S *.o > nul 2>&1
      del /S *.err > nul 2>&1

      echo   %%t_sdcc_iy.lib
   
      z80asm -d -ns -nm -Mo -IXIY -x%%t_sdcc_iy -D__SDCC -D__SDCC_IY @target/%%t/library/%%t_sdcc_iy.lst
      move /Y %%t_sdcc_iy.lib lib

      del /S *.o > nul 2>&1
      del /S *.err > nul 2>&1
      
   ) else (

      echo.
      echo target %%t unknown
   
   )
)

echo.

