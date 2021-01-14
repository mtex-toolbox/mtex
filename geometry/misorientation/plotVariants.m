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
% Options
%  variantMap - Variant order
%  id         - return parent variant id instead of parent ori
%

oriParent = getClass(varargin,'orientation',orientation.id(p2c.CS));
hChild = getClass(varargin,'Miller',Miller(0,0,1,p2c.SS,'hkl'));

% compute variants
vars = variants(p2c,oriParent);

% maybe we should renumber them
variantMap = get_option(varargin,'variantMap',1:length(vars));

% plot variants with equivalent orientations
plotPDF(vars,ind2color(variantMap),hChild,...
  'antipodal','MarkerEdgeColor','black',varargin{:});

% plot unique variants with label
hold on
plotPDF(vars,'label',variantMap,'nosymmetry', ...
  'MarkerFaceColor','none','MarkerEdgeColor','none',varargin{:});
hold off

% change figure name
set(gcf,'Name',strcat('child variants pole figure'),'NumberTitle','on');
