rem @echo off
set project=AmplaProject.xml
set authstore=AuthStore.xml

xcopy External\lib Output\lib /E /Y /I 
xcopy External\css Output\css /E /Y /I 
xcopy External\images Output\images /E /Y /I 
xcopy External\*.exe Working\*.exe /Y /I 
xcopy External\lib\chili\csharp.js Output /Y /I

set nxslt=Working\nxslt.exe

set lang=en
set language=..\en.words.html

rem set language=..\pt-BR.Words.html
rem set lang=pt-br

rem set language=..\zh-chs.html
rem set lang=zh-chs


%nxslt% %project% StyleSheets\Project.Normalize.xslt -o Working\project.xml language=%language%
%nxslt% Working\project.xml StyleSheets\Project.LinkFrom.xslt -o Working\project.links.from.xml
%nxslt% Working\project.links.from.xml StyleSheets\Project.LinkTo.xslt -o Working\project.links.xml
%nxslt% Working\project.links.xml StyleSheets\Project.Flow.xslt -o Working\project.flow.xml

%nxslt% Working\project.links.xml StyleSheets\Project.Security.xslt -o Working\project.security.xml
%nxslt% %authstore% StyleSheets\Authstore.Normalize.xslt -o Working\authstore.xml projectSecurity=..\Working\project.security.xml

%nxslt% Working\project.xml       StyleSheets\Document.CodeItems.xslt  -o output\Project.CodeItems.html

%nxslt% Working\project.links.xml StyleSheets\Project.Translations.xslt -o output\translations.upload.html

%nxslt% Working\project.links.xml StyleSheets\Project.Downtime.xslt -o Working\downtime.xml

%nxslt% Working\project.links.xml StyleSheets\Document.Summary.xslt -o Output\Project.Summary.html lang=%lang%
%nxslt% Working\authstore.xml StyleSheets\Document.Security.xslt -o Output\Project.Security.html

%nxslt% Working\downtime.xml StyleSheets\Document.Downtime.xslt -o Output\Project.Downtime.html

%nxslt% Working\project.links.xml StyleSheets\Project.Metrics.xslt -o working\metrics.xml
%nxslt% Working\metrics.xml StyleSheets\Project.Mindmap.xslt -o Output\Project.Metrics.mm
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.Report.xslt -o Output\Project.Metrics.html

%nxslt% Working\project.links.xml StyleSheets\Document.Frames.xslt -o Output\index.html
%nxslt% Working\project.links.xml StyleSheets\Document.Hierarchy.xslt -o Output\hierarchy.html 
%nxslt% Working\project.links.xml StyleSheets\Document.ItemTypes.xslt -o Output\types.html
%nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\all.html
%nxslt% Working\project.links.xml StyleSheets\Document.Properties.xslt -o Output\prop.html includeChildItems=false

%nxslt% Working\project.links.xml StyleSheets\Project.Metrics.xslt -o working\metrics.xml
%nxslt% Working\metrics.xml StyleSheets\Project.Mindmap.xslt -o Output\Project.Metrics.mm
%nxslt% Working\metrics.xml StyleSheets\Document.Metrics.xslt -o Output\metrics.html

%nxslt% Working\project.links.xml StyleSheets\Document.Translations.xslt -o Output\translations.html

%nxslt% Working\project.links.xml StyleSheets\Document.Warnings.xslt -o Output\Warnings.html
%nxslt% working\project.links.xml StyleSheets\File.ItemId.Fullname.Type.xslt -o Output\Id.Fullname.Type.txt


rem %nxslt% Working\project.links.xml StyleSheets\Document.Browser.Testing.xslt -o Output\Project.Testing.html

rem nxslt %project% StyleSheets\Project.Normalize.xslt -o Results\project.xml
rem nxslt results\project.xml StyleSheets\Project.LinkFrom.xslt -o Results\project.links.from.xml
rem nxslt results\project.links.from.xml StyleSheets\Project.LinkTo.xslt -o Results\project.links.xml
rem nxslt results\project.xml StyleSheets\Project.Equipment.xslt -o Results\equipment.xml
rem nxslt results\project.links.xml StyleSheets\Document.Browser.xslt    -o Results\Browser.html
rem nxslt results\project.links.xml StyleSheets\Document.Properties.xslt -o Results\Properties.html
rem nxslt results\project.xml       StyleSheets\Document.CodeItems.xslt  -o Results\CodeItems.html
rem nxslt results\project.xml       StyleSheets\Document.ItemTypes.xslt  -o Results\ItemTypes.html
rem nxslt results\project.xml       StyleSheets\Document.Warnings.xslt   -o Results\Warnings.html

rem pause
