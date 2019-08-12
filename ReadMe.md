# Windows-Search-Helper

## An attempt to make Windows Search suck less.

### Search within all your plain text files really fast:


![Before and After Demo](demo/BeforeAndAfter_720x480.gif?raw=true "Before and After Demo")
___
#### Choose which locations you want to be able to search (you may have already done this):
Open Windows Indexing Options and click the Modify button. From here select all the locations to search and select OK.

![Indexing Options](demo/IndexingOptions.png?raw=true "Indexing Options")

#### Then for most users, just do this:
1. Shift+Right click on **RegisterPlainTextFilterForAll.bat** and select *Run as Administrator*.
2. Shift+Right click on **RebuildWindowsSearchIndex.bat** and select *Run as Administrator*.
3. It might take several minutes rebuild the index after the Windows Search service is restarted, but afterwards plain text searches should produce better results.


##### Notes:

* Helpful when setting up a new computer.
* Search within any file comprised of plain text: html, xml, Visual Studio project files, etc, regardless of markup.
* Using Null filters can greatly reduce the size of the Windows Search index. It is generally used for binary files.
* For most users, these scripts need be run only once, hence why these are scripts and not an app.
* All scripts return an exit code of 0 on success; 1 on failure.
* These scripts need to be run as Administrator.

**Pro Tip:** Create a task in Windows Task Scheduler to run **RebuildWindowsSearchIndex.bat** once a week to keep the search index optimized.

___
## Scripts:
### RegisterPlainTextFilterForAll.bat
Configures Windows Search to index the contents of all files which have any of the file extensions below as plain text files. If the file extension is already registered with a different filter, it will be saved so that it may be later restored.

##### File extensions:
  .a .ada .adb .addin .ads .ahk .ammo .ans .arena .as .asc .ascx .asm .asp .aspx .asx .atr .au3 .aut .aux .axl .bas .bash .bash_login .bash_logout .bash_profile .bashrc .bat .bcp .bhc .bib .body .bot .bowerrc .bsh .c .camera .cbd .cbl .cc .cdb .cdc .cfg .cfm .cgi .clj .cljs .cljx .clojure .cls .cmake .cmd .cnf .cob .code-workspace .coffee .conf .config .cpp .cs .csa .csdl .cshtml .csproj .css .csv .csx .ctl .cue .cxx .d .dbs .def .defs .dfm .dic .diff .diz .dob .docbook .dockerfile .dos .dot .dotsettings .dpk .dpr .dsm .dsp .dsr .dsw .dtd .editorconfig .edmx .edn .efx .ent .ext .eyaml .eyml .f .f2k .f90 .f95 .faq .filters .fky .for .frames .frm .fs .fsi .fsscript .fsx .g2skin .gametype .gemspec .generate .git .gitattributes .gitconfig .gitignore .gitmodules .go .gore .gradle .gsc .h .handlebars .hbs .hh .hpp .hs .hta .htd .htm .html .htt .hud .hxa .hxc .hxk .hxt .hxx .i .ibq .ics .idl .idq .idx .il .iml .impacts .inc .inf .ini .inl .instance .inview .inx .isl .iss .itcl .item .jade .jav .java .js .jscsrc .jsfl .jshintrc .jshtm .json .jsp .jsx .kci .kix .kml .las .less .lgn .lhs .linq .lisp .litcoffee .log .lsp .lst .lua .m .m3u .mak .makefile .map .mapcycle .markdown .master .material .md .mdoc .mdown .mdtext .mdtxt .mdwn .menu .miscents .mission .mjs .mk .mkd .mkdn .ml .mli .ms .msl .mx .name .nav .nfo .npc .npmignor .nsh .nsi .nt .objectives .odh .odl .outfitting .pag .pas .patch .php .php3 .php4 .phtml .pl .pl6 .player .pln .plx .pm .pm6 .pod .poses .pp .prc .pro .profile .properties .props .ps .ps1 .psd1 .psgi .psm1 .py .pyproj .pyw .q3asm .qe4 .r .rb .rbw .rc .rc2 .rct .rdf .recent .reg .rej .resx .rgs .rhistory .rmd .rprofile .rs .rt .rul .s .sample .scc .scm .script .scss .ses .settings .sf .sh .shader .shfbproj .shock .shtm .shtml .sif .skl .sln .sma .smd .sml .sol .sp .spb .spec .sps .sql .ss .ssdl .st .str .sty .stype .sun .sv .svg .svgz .svh .t .tab .targets .tcl .tdl .teams .terrain .tex .theme .thy .tlh .tli .toc .tpl .trg .ts .tsx .tt .ttinclude .tui .tuo .txt .udf .udt .url .user .usr .v .vb .vbproj .vbs .vcproj .vcs .vcxproj .vdproj .vh .vhd .vhdl .viw .voice .vscontent .vsdir .vsprops .vspscc .vsscc .vssettings .vssscc .vstdir .vstheme .vsz .vxml .wml .wnt .wpn .wri .wsdl .wtx .wxi .wxl .wxs .xaml .xhtml .xlf .xliff .xml .xrc .xsd .xsl .xslt .xsml .xul .yaml .yml .zsh

**Usage:**

    RegisterPlainTextFilterForAll <No Parameters>


**Demo:**
![Register Extensions Demo](demo/RegisterExtensions_1280x720.gif?raw=true "Register Extensions Demo")
___
### RegisterPlainTextFilterForFileExt.bat
  Configures Windows Search to index the contents of all files with the specified extension as if they are plain text files. If the file extension is already registered with a different filter, it will be saved so that it may be later restored.

**Usage:**

    RegisterPlainTextFilterForFileExt [.]Extension

      Extension    Name of the extension to register, optionally prefixed by "."

    Examples:
      C:\>RegisterPlainTextFilterForFileExt
        Prompts for the file extension.
    
      C:\>RegisterPlainTextFilterForFileExt "sln"
        Registers a Windows Search plain text filter for .sln files.
    
      C:\>RegisterPlainTextFilterForFileExt .sln
        Registers a Windows Search plain text filter for .sln files.
___
### RegisterPropertiesOnlyFilterForFileExt.bat
  Configures Windows Search to index only the file properties (and not the contents) of files with the specified extension. If the file extension is already registered with a different filter, it will be saved so that it may be later restored.

**Usage:**

    RegisterPropertiesOnlyFilterForFileExt [.]Extension

      Extension    Name of the extension to register, optionally prefixed by "."

    Examples:
      C:\>RegisterPropertiesOnlyFilterForFileExt
        Prompts for the file extension.
    
      C:\>RegisterPropertiesOnlyFilterForFileExt "sln"
        Registers a Windows Search properties-only filter for .sln files.
    
      C:\>RegisterPropertiesOnlyFilterForFileExt .sln
        Registers a Windows Search properties-only filter for .sln files.
___
### RegisterNullFilterForAll.bat
Configures Windows Search to ignore the contents of all files which have any of the below file extensions (generally binary files). If the file extension is already registered with a different filter, it will be saved so that it may be later restored.

##### File extensions:
  .386 .aif .aifc .aiff .aps .art .asf .au .avi .ba .baml .bi .bin .bkf .bmp .bsc .bti .cab .cache .cda .cgm .cod .com .cpl .cpt .cub .cur .dax .dbg .dca .dct .desklink .dex .dgn .dib .dl_ .dll .drv .drx .dvx .dwg .emf .eng .eps .etp .ex_ .exe .exp .eyb .fnd .fnt .fon .ghi .gif .gz .hdp .hqx .icm .ico .igr .ilk .imc .in_ .ino .ins .inv .jbf .jds .jfif .jpe .jpeg .jpg .key .latex .ldb .lib .m14 .m1v .ma .mapimail .mdb .mdb2 .mid .midi .mmf .mov .movie .mp2 .mp2v .mp3 .mpa .mpe .mpeg .mpg .mpp .mpv2 .mshc .msm .mso .mv .mydocs .ncb .o .obj .obs .oc_ .ocx .opt .par .pc6 .pcd .pch .pdb .pds .pic .pid .pma .pmc .PML .pmr .png .ppn .psd .pth .pvk .res .resources .rle .rmi .rose .rpc .rsc .rsp .sbr .sc2 .scd .sch .sit .snd .sr_ .sy_ .sym .sys .tap .tar .tbl .tgz .tlb .tsp .ttc .ttf .vbx .vue .vxd .wav .wax .wdp .wll .wlt .wm .wma .wmf .wmp .wmv .wmx .wmz .wsi .wsz .wvx .xesc .xix .xor .z .z96 .zfsendtotarget .zvf

**Usage:**

    RegisterNullFilterForAll <No Parameters>
___
### RegisterNullFilterForFileExt.bat
  Configures Windows Search to ignore the contents of all files with the specified extension (helpful for binary files). If the file extension is already registered with a different filter, it will be saved so that it may be later restored.

**Usage:**

    RegisterNullFilterForFileExt [.]Extension

      Extension    Name of the extension to register, optionally prefixed by "."

    Examples:
      C:\>RegisterNullFilterForFileExt
        Prompts for the file extension.
    
      C:\>RegisterNullFilterForFileExt "tar"
        Registers a Windows Search null filter for .tar files.
    
      C:\>RegisterNullFilterForFileExt .tar
        Registers a Windows Search null filter for .tar files.
___
### RestoreFilterForFileExt.bat
  Configures Windows Search to restore the original search filter for the specified file extension. If the original search filter is not found, no operation is performed.

**Usage:**

    RestoreFilterForFileExt [.]Extension

      Extension    Name of the extension to restore, optionally prefixed by "."

    Examples:
      C:\>RestoreFilterForFileExt
        Prompts for the file extension.
    
      C:\>RestoreFilterForFileExt "sln"
        Restores the original Windows Search filter for .sln files.
    
      C:\>RestoreFilterForFileExt .sln
        Restores the original Windows Search filter for .sln files.
___
### RebuildWindowsSearchIndex.bat
  Stops the Windows Search service, deletes the Windows Search index, then restarts the Windows Search service which in turn rebuilds the index. The default location for the index is *"C:\ProgramData\Microsoft\Search\Data"*
  
**Usage:**

    RebuildWindowsSearchIndex <No Parameters>
___
### DeleteWindowsSearchIndex.bat
  Stops the Windows Search service then deletes the Windows Search index. The default location for the index is *"C:\ProgramData\Microsoft\Search\Data"*
  
**Usage:**

    DeleteWindowsSearchIndex <No Parameters>
___
### RestartWindowsSearchService.bat
  Stops the Windows Search service (if necessary) then starts it back up.
  
**Usage:**

    RestartWindowsSearchService <No Parameters>
___
### StartWindowsSearchService.bat
  Starts the Windows Search service if it is not already running.
  
**Usage:**

    StartWindowsSearchService <No Parameters>
___
### StopWindowsSearchService.bat
  Stops the Windows Search service if it is not already stopped.
  
**Usage:**

    StopWindowsSearchService <No Parameters>


