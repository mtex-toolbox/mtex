function plotUVW(cs,varargin)
% plot symmetry
%
% Input
%  s - symmetry
%
% Output
%
% Options
%  antipodal      - include <VectorsAxes.html antipodal symmetry>

mtexFig = newMtexFigure(varargin{:});

% which directions to plot
m = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{0,1,1},{1,0,1},{1,1,1},cs,'uvw');

m = unique(m);
options = [{'symmetrised','labeled','MarkerEdgeColor','k','grid','doNotDraw',...
  'backgroundColor','w'},varargin];
if ~check_option(varargin,'complete'), options = [options,{'upper'}]; end

% plot them
hG = holdOn(mtexFig.gca); %#ok<NASGU>
for i = 1:length(m)
  m(i).scatter(options{:});
end
clear hG


% postprocess figure
setappdata(gcf,'CS',cs);
set(gcf,'tag','ipdf');
mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
