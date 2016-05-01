rem @echo off
set project=AmplaProject.xml
set authstore=AuthStore.xml

xcopy External\lib Output\lib /E /Y /I 
xcopy External\css Output\css /E /Y /I 
xcopy External\images Output\images /E /Y /I 
xcopy "Library\bootstrap 2.3.2" Output\bootstrap /E /Y /I
xcopy "Library\jquery 1.10.2" Output\jquery /E /Y /I

if EXIST Working goto Working_exists
mkdir Working
:Working_exists

set nxslt=.\Library\nxslt\nxslt.exe
set nxslt3=.\Library\nxslt\nxslt3.exe
set graphviz=.\Library\GraphViz-2.30.1\bin
set dotml=.\Library\dotml-1.4
set xsltproc=.\Library\libxml\bin\xsltproc.exe 

set lang=en
set language=..\en.words.html

rem set language=..\pt-BR.Words.html
rem set lang=pt-br

rem set language=..\zh-chs.html
rem set lang=zh-chs

if EXIST Output\Graphs goto graphs_exists
mkdir Output\Graphs
:graphs_exists

del Working\Graphs\*.* /Q
del Output\Graphs\*.* /Q

@echo === Normalise ===
%nxslt% %project% StyleSheets\Project.Normalize.xslt -o Working\project.xml language=%language%	
%nxslt% Working\project.xml StyleSheets\Project.LinkFrom.xslt -o Working\project.links.from.xml
%nxslt% Working\project.links.from.xml StyleSheets\Project.LinkTo.xslt -o Working\project.links.xml
%nxslt% Working\project.links.xml StyleSheets\Project.Flow.xslt -o Working\project.flow.xml
%nxslt% Working\project.links.xml StyleSheets\Project.Expressions.xslt -o Working\project.expressions.xml

@echo === Security ===
%nxslt% Working\project.links.xml StyleSheets\Project.Security.xslt -o Working\project.security.xml
%nxslt% %authstore% StyleSheets\Authstore.Normalize.xslt -o Working\authstore.xml projectSecurity=..\Working\project.security.xml

@echo === Bootstrap ===
%nxslt% Working\project.links.xml       StyleSheets\Bootstrap.ReportingPoints.xslt  -o Output\Bootstrap.Modules.html
%nxslt% Working\project.links.xml       StyleSheets\Bootstrap.CodeItems.xslt		-o Output\Bootstrap.CodeItems.html
%nxslt% Working\project.links.xml       StyleSheets\Bootstrap.Planning.xslt			-o Output\Bootstrap.Planning.html
%nxslt% Working\project.links.xml       StyleSheets\Bootstrap.EquipmentIds.xslt			-o Output\Bootstrap.EquipmentIds.html

@echo === Reporting Points ===
%nxslt% Working\project.links.xml		StyleSheets\Excel.Modules.Production.xslt -o Output\Excel.Modules.Production.xls
%nxslt% Working\project.links.xml		StyleSheets\Excel.Modules.Quality.xslt -o Output\Excel.Modules.Quality.xls
%nxslt% Working\project.links.xml		StyleSheets\Excel.Modules.Downtime.xslt -o Output\Excel.Modules.Downtime.xls
%nxslt% Working\project.links.xml		StyleSheets\Excel.Modules.Metrics.xslt -o Output\Excel.Modules.Metrics.xls

@echo === Variables ===
%nxslt% Working\project.links.xml       StyleSheets\Bootstrap.Variables.xslt  -o Output\Bootstrap.Variables.html
%nxslt% Working\project.links.xml		StyleSheets\Excel.Connectors.xslt -o Output\Excel.Connectors.xls

%nxslt% Working\project.links.xml		StyleSheets\Excel.Calendar.xslt -o Output\Excel.Calendar.xls
%nxslt% Working\project.links.xml		StyleSheets\Excel.Types.xslt -o Output\Excel.Types.xls

@echo === Expressions ===
%nxslt% Working\project.expressions.xml StyleSheets\Excel.Expressions.xslt -o Output\Excel.Expressions.xls

rem %nxslt% Working\project.expressions.xml StyleSheets\Document.Expressions.DotML.xslt -o Working\expressions.dotml
rem %nxslt% Working\expressions.dotml %dotml%\dotml2dot.xsl -o Working\expressions.gv
rem %graphviz%\dot.exe -Tpng Working\expressions.gv -o Output\Graphs\expressions.png

@echo === Downtime ===
%nxslt% Working\project.links.xml StyleSheets\Project.Downtime.xslt -o Working\downtime.xml
%nxslt% Working\downtime.xml StyleSheets\Document.Downtime.xslt -o Output\Project.Downtime.html
%nxslt% Working\downtime.xml StyleSheets\Bootstrap.Downtime.xslt -o Output\Bootstrap.Downtime.html
%nxslt% Working\downtime.xml StyleSheets\Excel.Downtime.xslt -o Output\Excel.Downtime.xls

@echo === Interfaces ===
%nxslt% Working\project.xml       StyleSheets\Document.Interfaces.xslt  -o Output\Project.Interfaces.html

@echo === Code ===
%nxslt% Working\project.xml       StyleSheets\Document.CodeItems.xslt  -o Output\Project.CodeItems.html

@echo === Translations ===
%nxslt% Working\project.links.xml StyleSheets\Project.Translations.xslt -o Output\translations.upload.html
%nxslt% Working\project.links.xml StyleSheets\Document.Translations.xslt -o Output\translations.html

@echo === Inventory ===
%nxslt% Working\project.links.xml StyleSheets\Project.Inventory.xslt -o Working\inventory.xml

%nxslt% Working\inventory.xml StyleSheets\Document.Inventory.DotML.xslt -o Working\inventory.dotml
%nxslt% Working\inventory.dotml %dotml%\dotml2dot.xsl -o Working\inventory.gv
%graphviz%\dot.exe -Tpng Working\inventory.gv -o Output\Graphs\Inventory.png

cls
@echo === Graphs ===
%xsltproc% -o Working\graph.files.xml StyleSheets\Document.Graphs.DotML.xslt Working\project.links.xml

rem %nxslt% Working\inventory.xml StyleSheets\Document.Inventory.Materials.DotML.xslt -o Working\inventory.materials.dotml
%xsltproc% -o Working\inventory.material.files.xml StyleSheets\Document.Inventory.Materials.DotML.xslt Working\inventory.xml 
rem %nxslt% Working\inventory.materials.dotml %dotml%\dotml2dot.xsl -o Working\inventory.materials.gv
rem %graphviz%\dot.exe -Tpng Working\inventory.materials.gv -o Output\Project.Inventory.Materials.png

@echo === Metrics ===
%nxslt% Working\project.links.xml StyleSheets\Project.Metrics.xslt -o Working\metrics.xml
%xsltproc% -o Working\metrics.files.xml StyleSheets\Document.Metrics.DotML.xslt Working\metrics.xml 
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.Mindmap.xslt -o Output\Project.Metrics.mm
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.Report.xslt -o Output\Project.Metrics.html

cd Working\Graphs
for /F "usebackq" %%i in (`dir /b *.cmd`) DO call %%i
cd ..\..

@echo === Project ===
%nxslt% Working\project.links.xml StyleSheets\Document.Summary.xslt -o Output\Project.Summary.html lang=%lang%
%nxslt% Working\project.links.xml StyleSheets\Document.Equipment.xslt -o Output\Project.Equipment.html lang=%lang%
%nxslt% Working\authstore.xml StyleSheets\Document.Security.xslt -o Output\Project.Security.html
%nxslt% Working\authstore.xml StyleSheets\Excel.Security.xslt -o Output\Excel.Security.xls

%nxslt% Working\project.links.xml StyleSheets\Document.Frames.xslt -o Output\index.html
%nxslt% Working\project.links.xml StyleSheets\Document.Hierarchy.xslt -o Output\hierarchy.html 
%nxslt% Working\project.links.xml StyleSheets\Document.ItemTypes.xslt -o Output\types.html
%nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\all.html
rem %nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\prop.html includeChildItems=false

%nxslt% Working\project.links.xml StyleSheets\Document.Warnings.xslt -o Output\Warnings.html
%nxslt% working\project.links.xml StyleSheets\File.ItemId.Fullname.Type.xslt -o Output\Id.Fullname.Type.txt

rem pause
