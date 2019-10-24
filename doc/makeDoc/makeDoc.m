function makeDoc(varargin)
% build help with the DocHelp Toolbox
%

% load doc toolbox
warning off
addpath(fullfile(pwd,'..','..','..','makeDoc'))
addpath(fullfile(pwd,'..','..','..','makeDoc','tools'))
warning on

if check_option(varargin,'clear')
  !rm -r ../html/*
  !rm -r ./tmp/*
%  mtexdata clear
end

% help settings
clear
close all
mtex_settings
setMTEXpref('FontSize',12)
setMTEXpref('figSize',0.4)
setMTEXpref('generatingHelpMode',true);
set(0,'FormatSpacing','compact')
set(0,'DefaultFigureColor','white');
plotx2east
plotzOutOfPlane

outDir = fullfile(mtex_path,'doc','html');
tmpDir = fullfile(mtex_path,'doc','makeDoc','tmp');
style = fullfile(pwd,'general','publish.xsl');

% function reference files
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

% documentation files
mtexDocFiles = ...
  DocFile( fullfile(mtex_path,'doc'));
mtexDocFiles = exclude(mtexDocFiles,'makeDoc','html');

% some files that does not need to be published
mtexGeneralFiles = [DocFile(fullfile(mtex_path,'COPYING.txt')) ...
  DocFile(fullfile(mtex_path,'README.md')) ...
  DocFile(fullfile(mtex_path,'VERSION'))];
productPage = DocFile(fullfile(mtex_path,'doc','makeDoc','general','DocumentationMatlab.html'));

copy([mtexGeneralFiles,productPage],outDir)

% make toolbox xml -> will be included into all pages
makeToolboxXML('general','name','MTEX',...
  'fullname','<b>MTEX</b> - A MATLAB Toolbox for Quantitative Texture Analysis',...
  'versionname',getMTEXpref('version'),...
  'procuctpage','DocumentationMatlab.html')

% make help toc
makeHelpToc([mtexFunctionFiles mtexDocFiles],'DocumentationMatlab',fullfile(outDir,'helptoc.xml'));

% Publish Function Reference and Doc
publish(mtexFunctionFiles,'outDir',outDir,'tmpDir',tmpDir,'evalCode',true,'styleSheet',style);

% Publish Doc
publish(mtexDocFiles,'outDir',outDir,'tmpDir',tmpDir,'evalCode',true,'styleSheet',style);

% check for dead links
%deadlink(mtexDocFiles,outputDir);

% Enable search in documentation
builddocsearchdb(outDir);

% set back mtex options
setMTEXpref('generatingHelpMode',false);

end
