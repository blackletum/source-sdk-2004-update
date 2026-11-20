Source SDK 2004 (HL2 branch) - VPC project generation
=====================================================

WHAT THIS IS
  The 2004 SDK only ships Visual Studio .NET 2003 solutions (Everything_SDK.sln, Game_HL2.sln,
  Game_SDK.sln) which modern Visual Studio cannot open. These scripts let you generate
  VS2013-format projects (.vcxproj + .sln) with Valve's own project generator (VPC), the same
  way the 2013 SDK does. None of the original .sln / .vcproj files were modified or removed.

THE TWO SOLUTIONS  (run the .bat files from the src_mod folder; they work from anywhere)

  createallprojects.bat   vpc /hl2 /sdk /2013 +everything /mksln everything.sln
      EVERYTHING - 20 projects: every project of the original SDK solutions
        15 tools     glview  height2normal  serverplugin_empty  studiomdl  tgadiff  vbsp  vice
                     vprojtomake  vrad  vrad_launcher  vtf2tga  vtfdiff  vvis  vvis_launcher  xwad
         1 library   vgui_controls
         4 game DLLs Client (HL2)  Server (HL2)  Client (SDK)  Server (SDK)
      (Everything_SDK.sln's "client" and "hl" projects are the SDK-template ones, Game_HL2.sln's are
       the HL2 ones; EVERYTHING contains both so nothing from the three old solutions is missing.)

  creategameprojects.bat  vpc /hl2 /2013 +game /mksln games.sln
      HL2 - 3 projects: what it takes to build the HL2 game binaries
        Client (HL2)  Server (HL2)  vgui_controls   (the client links against vgui_controls.lib)

  The two scripts are different on purpose, like Valve's 2013 pair: different group (+everything /
  +game, see vpc_scripts\groups.vgc) and different games (/hl2 /sdk vs. /hl2 only, see
  vpc_scripts\default.vgc and projects.vgc).

HOW TO USE
  1. Run  createallprojects.bat  and/or  creategameprojects.bat  (needs nothing but the repo).
  2. Open everything.sln or games.sln in VS2013 or VS2022. The projects use PlatformToolset
     "v120_xp", so the VS2013 (v120) toolset must be installed. If VS2022 offers to retarget /
     upgrade the solution, decline - keep v120_xp.
  3. Pick Debug|Win32 or Release|Win32 and build. vgui_controls (a static lib) is built first and
     replaces the 132-byte placeholder lib\public\vgui_controls.lib; the client links against it.
  4. Output goes to the same places as the old projects:
       HL2 client.dll / server.dll  ->  game\hl2\bin
       SDK client.dll / server.dll  ->  game\sdk\bin
       the tools (.exe and the vrad / vvis / serverplugin_empty DLLs)  ->  game\bin
       (vprojtomake builds vcpm.exe in Release, as before)
     Each project builds in a Debug_<game> / Release_<game> (games) or Debug / Release (tools)
     folder next to its .vcxproj.

  The generated .sln / .vcxproj files are listed in src_mod\.gitignore. After changing any .vpc or
  vpc_scripts file, just run the .bat again.

FILES
  creategameprojects.bat / createallprojects.bat   the two generators described above
  devtools\bin\vpc.exe, vpccrccheck.exe   Valve's generator + CRC helper (from the 2013 SDK)
  vpc_scripts\default.vgc    game list ("HL2", "SDK") and the SOURCESDK switch
  vpc_scripts\projects.vgc   project name -> .vpc script (and which game each script belongs to)
  vpc_scripts\groups.vgc     groups: everything, game, gamedlls
  vpc_scripts\source_*.vpc   shared compiler / linker settings (trimmed copies of Valve's 2013 scripts):
                               source_dll_*      client / server DLLs and the DLL tools
                               source_exe_*      the tools (source_exe_con_* = console, source_exe_base = GUI)
                               source_lib_*      static libraries (vgui_controls)
  vpc_scripts\definitions\win32_2010.def   property names / enum strings VPC accepts
  the project scripts (converted once from the old .vcproj files, next to them):
    cl_dll\client_hl2.vpc  cl_dll\client_sdk.vpc  dlls\server_hl2.vpc  dlls\server_sdk.vpc
    vgui2\controls\vgui_controls.vpc
    utils\<tool>\<tool>.vpc  (utils\serverplugin_sample\serverplugin_empty.vpc)

NOT INCLUDED
  utils\smdlexp and utils\vtaexp (3ds Max exporters) are not part of any of the three shipped
  solutions and need the Max SDK, so they are not in either solution.

WHAT CHANGED VERSUS THE OLD .vcproj BUILD (all on purpose)
  - Runtime library: /ML(d) -> /MT(d). VS2013 has no single-threaded CRT.
  - Default libraries: the prebuilt lib\public\*.lib files were built with VS2003 and ask the linker for libc /
    libcd / libcp / libcpd (the single-threaded C and C++ runtimes). VS2013 does not have them, so the DLL and
    EXE base scripts list them in $IgnoreSpecificLibrary (the code is linked against the /MT runtime instead).
  - wchar_t is NOT a built-in type (/Zc:wchar_t-), matching the prebuilt lib\public\*.lib files.
  - For-loop scope: /Zc:forScope- (the VS2003 default: a variable declared in "for ( int i ...)" stays
    visible after the loop). Valve's 2013 scripts force the standard rule (/Zc:forScope), which the 2004
    code violates in ~100 places (vbsp, vrad, studiomdl, vgui_controls ...).
  - "DEBUG" is not defined in debug builds unless the old project defined it itself (vbsp,
    vprojtomake). The 2013 scripts define it; 2004 code uses #ifdef DEBUG.
  - "WIN32" is only defined where the old project defined it (not for client/server).
  - Same preprocessor defines and include paths as the old projects, per configuration
    (fopen=dont_use_fopen only in Debug, as before). Include folders that do not exist on disk
    (e.g. the bogus "..\..\dlls" of the game DLLs, ..\vmpi\mysql\include) were dropped and are
    listed at the top of the .vpc file.
  - C++ exceptions and character set follow the old project (VS2003 default for a project that
    does not say: exceptions ON, character set "Not Set"); the 2013 base scripts default to off / MBCS.
  - Warnings: /W3 (was /W3 or /W4) and never treated as errors (/WX off).
  - Obsolete options dropped: /G6 /G7 (OptimizeForProcessor), /YX, browse info, assembly listings.
    (The launchers' real precompiled header, stdafx.h, is kept.)
  - Release/Debug codegen otherwise comes from Valve's 2013 base scripts (/fp:fast, /arch:SSE, /Gy,
    /GF, /Zi). These are the knobs to revisit if behaviour differs from a VS2003 build.
  - Configuration names are now "Debug" / "Release" (were "Debug HL2", "Release SDK", ...).
  - Files that were ExcludedFromBuild in the old projects (HL2: 54 client / 84 server; SDK: 75 client /
    241 server - the code of the other game) are left out of the .vpc files and listed in a comment at
    the bottom of each one. Headers that the old projects referenced but that do not exist in this
    repo are listed as "MISSING ON DISK" comments.
  - Not carried over from the 2013 scripts: Perforce/signing steps, x64/Linux/OSX/X360/PS3,
    Valve's "skeleton project" (memoverride.cpp, tier1/tier0/vstdlib link entries), video libs.
    The 2004 projects list memoverride.cpp and their link libraries themselves.

WHAT TO EXPECT ON THE FIRST BUILD
  The 2004 code was last compiled with VS2003. Expect a first round of compile and link errors from
  the ten-year-newer VS2013 compiler and CRT (stricter C++, CRT header changes, memoverride.cpp vs.
  the static CRT, etc.). These are code issues, not project-generation issues. Known ones:
    vprojtomake uses its own MsXml2.Lib plus comsupp.lib
    vrad / vvis the old MySQL include folders are not in this repo
  Release|Win32 is the configuration that has been worked through so far. Debug|Win32 has not been built yet:
  it compiles code that Release leaves out (Debug-only blocks, Assert expressions) and links the debug static
  runtime (/MTd). public\tier0\memoverride.cpp carries the debug-runtime heap overrides as well (ported from
  Valve's 2013 file, not linked yet), so expect a round of errors in Debug too.
  Send the Output window text and they get fixed one batch at a time.

SOURCE FIXES FOR THE VS2013 COMPILER (the only edits to Valve's 2004 source so far)
  Kept as small as possible. Where Valve's 2006 / 2013 SDK changed the same spot the fix matches theirs
  (the strchr casts, brushbsp, bsplib, KeyValues, mstristrip, round -> V_round, the &Class:: callbacks, pow,
  <ctype.h>); the rest, including memoverride.cpp, are the minimal equivalent.
  public\vstdlib\strtools.h      Q_strrchr / Q_strstr: cast the result; the CRT now returns const char* for const input
  tier1\KeyValues.cpp            FindKey: const char * for the strchr() result
  dlls\vguiscreen.cpp            KeyValue: (char *) cast on strchr( const char * )
  game_shared\baseentity_shared.cpp   same
  public\tier1\tokenreader.h     operator= had no return type (C++ has no implicit int)
  utils\vbsp\brushbsp.cpp        "static s_NodeCount" had no type
  utils\common\bsplib.cpp        ArrayUsage / GlobUsage had no return type
  vgui2\controls\Panel.cpp       message map entry needs the explicit & on a member function pointer (C4867)
  utils\common\mstristrip.cpp    a std::list iterator cannot be built from NULL; return end() instead
  dlls\ai_movesolver.cpp         round() -> V_round() (VS2013's math.h declares its own round)
  utils\glview\glview.cpp, glview.vpc   <gl/glaux.h> / glaux.lib no longer exist; nothing from glaux is used
  dlls\hl2_dll\weapon_rpg.cpp, weapon_crossbow.cpp, weapon_physcannon.cpp
                                 SetThink / SetTouch / SetContextThink( Func ) needs ( &Class::Func ) (C3867)
  cl_dll\hud_bitmapnumericdisplay.cpp, dlls\TemplateEntities.cpp
                                 pow( 10, n ) is ambiguous since VS2005 (C2668): pow( 10.0f, n )
  dlls\hl2_dll\npc_BaseZombie.cpp   "static s_iAngryZombies" had no type
  dlls\baseentity.cpp            #include <ctype.h> (tolower)
  public\tier0\memoverride.cpp   also defines the heap functions the VS2005+ static runtime needs (_crtheap,
                                 _calloc_base, _recalloc, _malloc_crt ...). Without them the linker pulled the
                                 runtime's own heapinit.obj in: LNK2005 __heap_init already defined.
                                 Same set as Valve's 2013 file, but calloc / recalloc take (count, size).
                                 Debug builds get the same for the debug runtime (_calloc_dbg_impl, _recalloc_dbg,
                                 _aligned_*, _CrtGetReportHook ...), and _CrtDbgReport accepts a NULL format
                                 (the VS2013 debug runtime passes one for _ASSERT).

IF VPC ITSELF COMPLAINS
  Send the console output. The scripts were checked statically against win32_2010.def (property
  names, enum strings, braces, file existence, no duplicate files; every file of every old .vcproj
  is accounted for), but not executed with vpc.exe.
