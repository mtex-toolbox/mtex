function make_mtex_help(varargin)
% build help with the DocHelp Toolbox
%

if check_option(varargin,'clear')
  !find doc/UsersGuide -exec touch {} \;
  mtexdata clear
end

clear
close all
setMTEXpref('FontSize',12)
setMTEXpref('figSize',0.4)

addpath(fullfile(pwd,'..','..','doc'))
addpath(fullfile(pwd,'..','..','doc','tools'))


%%

plotx2east

global mtex_progress;
mtex_progress = 0;

setMTEXpref('generatingHelpMode',true);
set(0,'FormatSpacing','compact')
set(0,'DefaultFigureColor','white');


%% DocFiles
%

mtexFunctionFiles = [...
  DocFile( fullfile(mtex_path,'EBSDAnalysis')) ...
  DocFile( fullfile(mtex_path,'ODFAnalysis')) ...
  DocFile( fullfile(mtex_path,'PoleFigureAnalysis')) ...
  DocFile( fullfile(mtex_path,'plotting')) ...
  DocFile( fullfile(mtex_path,'geometry')) ...
  DocFile( fullfile(mtex_path,'interfaces')) ...
  DocFile( fullfile(mtex_path,'tools')) ];

%mtexFunctionFiles = exclude(mtexFunctionFiles,'Patala');

mtexDocFiles = ...
  DocFile( fullfile(mtex_path,'doc'));

mtexHelpFiles = [mtexFunctionFiles mtexDocFiles];

mtexGeneralFiles = [DocFile(fullfile(mtex_path,'COPYING.txt')) ...
  DocFile(fullfile(mtex_path,'README.txt')) ...
  DocFile(fullfile(mtex_path,'VERSION'))];


outputDir = fullfile(mtex_path,'help','mtex');
tempDir = fullfile(mtex_path,'help','tmp');


%% make productpage
%

makeToolboxXML('name','MTEX',...
  'fullname','<b>MTEX</b> - A MATLAB Toolbox for Quantitative Texture Analysis',...
  'versionname',getMTEXpref('version'),...
  'procuctpage','mtex_product_page.html')

%
copy(mtexGeneralFiles,outputDir)

% 
productpage = DocFile(fullfile(mtex_path,'help','general','mtex_product_page.html'));
copy(productpage,outputDir)

%% make function reference overview pages

makeFunctionsReference(mtexHelpFiles,'FunctionReference','outputDir',outputDir);

% make help toc
makeHelpToc(mtexHelpFiles,'Documentation','FunctionMainFile','FunctionReference','outputDir',outputDir);

% Publish Function Reference
publish(mtexFunctionFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false);


%% Publish Doc

publish(mtexDocFiles,'outputDir',outputDir,'tempDir',tempDir,'evalCode',true,'force',false);

%%

options.outputDir = outputDir;
options.publishSettings.outputDir = outputDir;
options.tempDir = tempDir;

view(mtexHelpFiles,options)


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

end
