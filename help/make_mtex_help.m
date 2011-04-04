%% build help with the DocHelp Toolbox
%

clear
close all

%%

plotx2east 

global mtex_progress;
mtex_progress = 0;

set_mtex_option('generate_help',true);
set(0,'FormatSpacing','compact')

c = get(0,'DefaultFigureColor');
set(0,'DefaultFigureColor','white');


%% DocFiles
% 

mtexFunctionFiles = [...
  DocFile( fullfile(mtex_path,'qta')) ...
  DocFile( fullfile(mtex_path,'geometry')) ...
  DocFile( fullfile(mtex_path,'tools')) ];
mtexExampleFiles = ...
  DocFile( getFiles(fullfile(mtex_path,'examples'),'*.m',false));
mtexDocFiles = ...
  DocFile( fullfile(mtex_path,'help','doc'));

mtexHelpFiles = [mtexFunctionFiles mtexExampleFiles mtexDocFiles];

mtexDocPictures = DocFile(getFiles(fullfile(mtex_path,'help','doc'),'*.png',true));

%%
% 

makeToolboxXML('name','MTEX',...
  'fullname','<b>MTEX</b> - A MATLAB Toolbox for Quantitative Texture Analysis',...
  'versionname',get_mtex_option('version'),...
  'procuctpage','mtex_product_page.html')

%%


docPath = fullfile(mtex_path,'help','mtex');
outputDir = fullfile(mtex_path,'help','html');
tempDir = fullfile(mtex_path,'help','tmp');

%%

copy(mtexDocPictures,outputDir)

%% Copy productpage

productpage = DocFile(fullfile(mtex_path,'help','general','mtex_product_page.html'));
copy(productpage,outputDir)

%% make function reference overview pages

makeFunctionsReference(mtexHelpFiles,'FunctionReference','outputDir',outputDir)

%% make help toc

makeHelpToc(mtexHelpFiles,'doc','FunctionMainFile','FunctionReference','outputDir',outputDir)
copyfile(fullfile(outputDir,'helptoc.xml'), docPath)

%%

makeHelpToc(mtexHelpFiles,'doc','FunctionMainFile','FunctionReference','outputDir',outputDir)
copyfile(fullfile(outputDir,'helptoc.xml'), docPath)

%% Publish Function Reference

publish(mtexFunctionFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false)

%% Publish Examples Reference

publish(mtexExampleFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false)

%%

src = struct(mtexExampleFiles);
src = [src.sourceInfo];

for k=1:numel(src)
  temp = docFile(getFiles(outputDir,[src(k).docName '*']));
  copy(temp,fullfile(mtex_path,'examples','html'))
end
copy(DocFile(getPublishGeneral),outputDir)



%% Publish Doc

publish(mtexDocFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false)


%%

options.outputDir = outputDir;
options.publishSettings.outputDir = outputDir;
options.tempDir = tempDir;

view(mtexHelpFiles,options)

%%

deadlink(mtexDocFiles,outputDir)

%% Enable search in documentation 
% (also F1 Help in recent matlab)

builddocsearchdb(outputDir);
copyfile(fullfile(outputDir,'helpsearch'),fullfile(docPath,'helpsearch'))


%% Build the help.jar

system(['jar -cf ' fullfile(docPath,'help.jar') ' -C ' outputDir ' .']);




