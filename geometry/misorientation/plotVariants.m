function plotVariants(p2c, varargin)
% plot pole figure of child variants
%
% Syntax
%   plotParent2Child(p2c)
%   plotParent2Child(p2c, oriParent)
%   plotParent2Child(p2c, hChild)
%   plotParent2Child(p2c, oriParent, hChild)
%
% Input
%  p2c       - parent to child @orientation relationship
%  oriParent - parent @orientation 
%  hChild    - @Miller, plotting direction for the pole figure
%

oriParent = getClass(varargin,'orientation',orientation.id(p2c.CS));
hChild = getClass(varargin,'Miller',Miller({0,0,1},{1,1,0},{1,1,1},p2c.SS,'hkl'));

% compute variants
vars = variants(p2c,oriParent,varargin{:});

% plot variants with equivalent orientations
plotPDF(vars,ind2color(1:length(vars)),hChild,...
  'antipodal','MarkerEdgeColor','black',varargin{:});
  
% plot unique variants with label
hold on
plotPDF(vars,'label',1:length(vars),'nosymmetry', ...
  'MarkerFaceColor','none','MarkerEdgeColor','none','add2all',varargin{:});
  hold off

% change figure name
set(gcf,'Name',strcat('child variants pole figure'),'NumberTitle','on');
