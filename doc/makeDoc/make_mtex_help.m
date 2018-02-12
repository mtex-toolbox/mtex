function make_mtex_help(varargin)
% build help with the DocHelp Toolbox
%

if check_option(varargin,'clear')
  !rm -r ../html/*
  !rm -r ./tmp/*
%  mtexdata clear
end

clear
close all
mtex_settings
setMTEXpref('FontSize',12)
setMTEXpref('figSize',0.4)

warning off
addpath(fullfile(pwd,'..','..','..','makeDoc'))
addpath(fullfile(pwd,'..','..','..','makeDoc','tools'))
warning on

%
plotx2east
plotzOutOfPlane

global mtex_progress;
mtex_progress = 0;

setMTEXpref('generatingHelpMode',true);
set(0,'FormatSpacing','compact')
set(0,'DefaultFigureColor','white');


% DocFiles
%

mtexFunctionFiles = [...
  DocFile( fullfile(mtex_path,'S2Fun')) ...
  DocFile( fullfile(mtex_path,'EBSDAnalysis')) ...
  DocFile( fullfile(mtex_path,'ODFAnalysis')) ...
  DocFile( fullfile(mtex_path,'PoleFigureAnalysis')) ...
  DocFile( fullfile(mtex_path,'TensorAnalysis')) ...
  DocFile( fullfile(mtex_path,'plotting')) ...
  DocFile( fullfile(mtex_path,'geometry')) ...
  DocFile( fullfile(mtex_path,'interfaces')) ...
  DocFile( fullfile(mtex_path,'tools')) ];



mtexDocFiles = ...
  DocFile( fullfile(mtex_path,'doc'));
mtexDocFiles = exclude(mtexDocFiles,'makeDoc','html');

mtexHelpFiles = [mtexFunctionFiles mtexDocFiles];

mtexGeneralFiles = [DocFile(fullfile(mtex_path,'COPYING.txt')) ...
  DocFile(fullfile(mtex_path,'README.md')) ...
  DocFile(fullfile(mtex_path,'VERSION'))];


outputDir = fullfile(mtex_path,'doc','html');
tempDir = fullfile(mtex_path,'doc','makeDoc','tmp');


% make productpage
%

makeToolboxXML('name','MTEX',...
  'fullname','<b>MTEX</b> - A MATLAB Toolbox for Quantitative Texture Analysis',...
  'versionname',getMTEXpref('version'),...
  'procuctpage','mtex_product_page.html')

%
copy(mtexGeneralFiles,outputDir)

% 
productpage = DocFile(fullfile(mtex_path,'doc','makeDoc','general','mtex_product_page.html'));
copy(productpage,outputDir)

% make function reference overview pages

makeFunctionsReference(mtexHelpFiles,'FunctionReference','outputDir',outputDir);

% make help toc
makeHelpToc(mtexHelpFiles,'Documentation','FunctionMainFile','FunctionReference','outputDir',outputDir);

% Publish Function Reference
publish(mtexFunctionFiles,'outputDir',outputDir,...
  'tempDir',tempDir,'evalCode',true,'force',false,'viewoutput',false);


% Publish Doc

publish(mtexDocFiles,'outputDir',outputDir,'tempDir',tempDir,...
  'evalCode',true,'force',false,'viewoutput',false);

%

options.outputDir = outputDir;
options.publishSettings.outputDir = outputDir;
options.tempDir = tempDir;

view(mtexDocFiles,options)

%
deadlink(mtexDocFiles,outputDir);

% Enable search in documentation
builddocsearchdb(outputDir);

% set back mtex options
setMTEXpref('generatingHelpMode',false);

end
