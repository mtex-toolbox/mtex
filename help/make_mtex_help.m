%% build help with the DocHelp Toolbox
%

% !find doc/UsersGuide -exec touch {} \;

clear
close all

%%

mtexdata clear

%%

plotx2east

global mtex_progress;
mtex_progress = 0;

setMTEXpref('generatingHelpMode',true);
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

mtexGeneralFiles = [DocFile(fullfile(mtex_path,'COPYING.txt')) ...
  DocFile(fullfile(mtex_path,'README.txt')) ...
  DocFile(fullfile(mtex_path,'VERSION'))];


%%


docPath = fullfile(mtex_path,'help','mtex');
outputDir = fullfile(mtex_path,'help','mtex');
tempDir = fullfile(mtex_path,'help','tmp');


%%
%

makeToolboxXML('name','MTEX',...
  'fullname','<b>MTEX</b> - A MATLAB Toolbox for Quantitative Texture Analysis',...
  'versionname',getMTEXpref('version'),...
  'procuctpage','mtex_product_page.html')


%%

copy(mtexDocPictures,outputDir)
copy(mtexGeneralFiles,outputDir)

%% Copy productpage

productpage = DocFile(fullfile(mtex_path,'help','general','mtex_product_page.html'));
copy(productpage,outputDir)

%% make function reference overview pages

makeFunctionsReference(mtexHelpFiles,'FunctionReference','outputDir',outputDir);

%% make help toc

makeHelpToc(mtexHelpFiles,'Documentation','FunctionMainFile','FunctionReference','outputDir',outputDir);
%copyfile(fullfile(outputDir,'helptoc.xml'), docPath);

%% Publish Function Reference

publish(mtexFunctionFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false);

%% Publish Examples Reference

publish(mtexExampleFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false);


%%

makeDemoToc(mtexExampleFiles,'outputDir',outputDir);
copyfile(fullfile(outputDir,'demos.xml'), fullfile(mtex_path,'examples'));


%%

src = struct(mtexExampleFiles);
src = [src.sourceInfo];

for k=1:numel(src)
  temp = DocFile(getFiles(outputDir,[src(k).docName '*']));
  copy(temp,fullfile(mtex_path,'examples','html'));
end
copy(DocFile(getPublishGeneral),fullfile(mtex_path,'examples','html'));


%% Publish Doc

publish(mtexDocFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false);
copy(mtexDocFiles,fullfile(mtex_path,'examples','UsersGuide'));

%%

options.outputDir = outputDir;
options.publishSettings.outputDir = outputDir;
options.tempDir = tempDir;

view(mtexHelpFiles,options)


%%

view(mtexExampleFiles,outputDir);

%%

deadlink(mtexDocFiles,outputDir);

%% Enable search in documentation
% (also F1 Help in recent matlab)

builddocsearchdb(outputDir);
%copyfile(fullfile(outputDir,'helpsearch'),fullfile(docPath,'helpsearch'));


%% Build the help.jar

%system(['jar -cf ' fullfile(docPath,'help.jar') ' -C ' outputDir ' .']);

%% set back mtex options

setMTEXpref('generatingHelpMode',false);
