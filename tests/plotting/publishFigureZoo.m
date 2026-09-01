function html = publishFigureZoo(varargin)
% publish figureZoo under the preferences the website build uses
%
% Syntax
%   publishFigureZoo
%   html = publishFigureZoo
%
% Output
%  html - the page that was written
%
% Description
% The size of a published figure comes from the preferences below and from
% .mtex-figure in the website css, which shows an image at half its pixel
% size. Reading the page anywhere else shows the figures at twice the size a
% reader sees them at, so compare them with each other rather than with the
% site.
%
% See also
% figureZoo check_publishedFigure

old = {getMTEXpref('FontSize'), getMTEXpref('figSize'), ...
  getMTEXpref('axisBox'), getMTEXpref('axisArea'), ...
  getMTEXpref('sphericalAxisHeight'), getMTEXpref('screenSize'), ...
  getMTEXpref('showRefFrame'), getMTEXpref('generatingHelpMode')};
restore = onCleanup(@() restorePrefs(old)); %#ok<NASGU>

% keep these in step with makeDoc.m in the website repository
setMTEXpref('FontSize',13)
setMTEXpref('figSize',0.5)
setMTEXpref('axisBox',[1096 480])
setMTEXpref('axisArea',368000)
setMTEXpref('sphericalAxisHeight',370)
setMTEXpref('screenSize',[1920 1080])
setMTEXpref('showRefFrame','off')
setMTEXpref('generatingHelpMode',true)

outDir = get_option(varargin,'outputDir',fullfile(tempdir,'figureZoo'));

% publish captures only figures whose Visible is 'on', so they come up on the
% screen while the page is written and there is no way around it
oldVis = get(0,'DefaultFigureVisible');
showThem = onCleanup(@() set(0,'DefaultFigureVisible',oldVis)); %#ok<NASGU>
set(0,'DefaultFigureVisible','on');

close all
html = publish(which('figureZoo'),'outputDir',outDir,'maxWidth',[],'catchError',false);
close all

disp(['figure zoo: ' html]);

end

% -------------------------------------------------------------------------
function restorePrefs(old)

name = {'FontSize','figSize','axisBox','axisArea','sphericalAxisHeight', ...
  'screenSize','showRefFrame','generatingHelpMode'};

for k = 1:numel(name), setMTEXpref(name{k},old{k}); end

end
