rem @echo off
set project=AmplaProject.xml
set authstore=AuthStore.xml

xcopy External\lib Output\lib /E /Y /I 
xcopy External\css Output\css /E /Y /I 
xcopy External\images Output\images /E /Y /I 

if EXIST Working goto Working_exists
mkdir Working
:Working_exists

set nxslt=Library\nxslt\nxslt.exe
set graphviz=Library\GraphViz-2.30.1\bin
set dotml=Library\dotml-1.4

set lang=en
set language=..\en.words.html

rem set language=..\pt-BR.Words.html
rem set lang=pt-br

rem set language=..\zh-chs.html
rem set lang=zh-chs

@echo === Normalise ===
%nxslt% %project% StyleSheets\Project.Normalize.xslt -o Working\project.xml language=%language%
%nxslt% Working\project.xml StyleSheets\Project.LinkFrom.xslt -o Working\project.links.from.xml
%nxslt% Working\project.links.from.xml StyleSheets\Project.LinkTo.xslt -o Working\project.links.xml
%nxslt% Working\project.links.xml StyleSheets\Project.Flow.xslt -o Working\project.flow.xml

@echo === Security ===
%nxslt% Working\project.links.xml StyleSheets\Project.Security.xslt -o Working\project.security.xml
%nxslt% %authstore% StyleSheets\Authstore.Normalize.xslt -o Working\authstore.xml projectSecurity=..\Working\project.security.xml

@echo === Code ===
%nxslt% Working\project.xml       StyleSheets\Document.CodeItems.xslt  -o Output\Project.CodeItems.html

@echo === Translations ===
%nxslt% Working\project.links.xml StyleSheets\Project.Translations.xslt -o Output\translations.upload.html
%nxslt% Working\project.links.xml StyleSheets\Document.Translations.xslt -o Output\translations.html

@echo === Inventory ===
%nxslt% Working\project.links.xml StyleSheets\Project.Inventory.xslt -o Working\inventory.xml
%nxslt% Working\inventory.xml StyleSheets\Document.Inventory.DotML.xslt -o Working\inventory.dotml
%nxslt% Working\inventory.dotml %dotml%\dotml2dot.xsl -o Working\inventory.gv
%graphviz%\dot.exe -Tpng Working\inventory.gv -o Output\Project.Inventory.png

%nxslt% Working\inventory.xml StyleSheets\Document.Inventory.Materials.DotML.xslt -o Working\inventory.materials.dotml
%nxslt% Working\inventory.materials.dotml %dotml%\dotml2dot.xsl -o Working\inventory.materials.gv
%graphviz%\dot.exe -Tpng Working\inventory.materials.gv -o Output\Project.Inventory.Materials.png

@echo === Downtime ===
%nxslt% Working\project.links.xml StyleSheets\Project.Downtime.xslt -o Working\downtime.xml
%nxslt% Working\downtime.xml StyleSheets\Document.Downtime.xslt -o Output\Project.Downtime.html

@echo === Metrics ===
%nxslt% Working\project.links.xml StyleSheets\Project.Metrics.xslt -o working\metrics.xml
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.Mindmap.xslt -o Output\Project.Metrics.mm
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.Report.xslt -o Output\Project.Metrics.html
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.DotML.xslt -o Working\metrics.dotml
%nxslt% Working\metrics.dotml %dotml%\dotml2dot.xsl -o Working\metrics.gv
%graphviz%\dot.exe -Tpng Working\metrics.gv -o Output\Project.Metrics.png

@echo === Project ===
%nxslt% Working\project.links.xml StyleSheets\Document.Summary.xslt -o Output\Project.Summary.html lang=%lang%
%nxslt% Working\authstore.xml StyleSheets\Document.Security.xslt -o Output\Project.Security.html

%nxslt% Working\project.links.xml StyleSheets\Document.Frames.xslt -o Output\index.html
%nxslt% Working\project.links.xml StyleSheets\Document.Hierarchy.xslt -o Output\hierarchy.html 
%nxslt% Working\project.links.xml StyleSheets\Document.ItemTypes.xslt -o Output\types.html
%nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\all.html
%nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\prop.html includeChildItems=false

%nxslt% Working\project.links.xml StyleSheets\Document.Warnings.xslt -o Output\Warnings.html
%nxslt% working\project.links.xml StyleSheets\File.ItemId.Fullname.Type.xslt -o Output\Id.Fullname.Type.txt

rem pause
