set nxslt=..\Library\nxslt\nxslt.exe

set graphviz=..\Library\GraphViz-2.30.1\bin
set dotml=..\Library\dotml-1.4

%nxslt% .\Build.Files.xml .\BuildToDotML.xslt -o ..\Working\buildfiles.dotml
%nxslt% ..\Working\buildfiles.dotml %dotml%\dotml2dot.xsl -o ..\Working\buildfiles.gv
%graphviz%\dot.exe -Tpng ..\Working\buildfiles.gv -o .\Build.Diagram.png
