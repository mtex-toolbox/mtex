function map = hsvColorMap(m)
% hue-saturation-value colour map
%
% The colours vary the hue of the hue-saturation-value colour model: they
% begin with red, pass through yellow, green, cyan, blue, magenta, and return
% to red. The map is particularly useful for displaying periodic functions.
%
% Syntax
%
%   map = hsvColorMap(m)   % an m x 3 colour map
%   map = hsvColorMap      % as many colours as the colour map of the current figure
%
%   % set the colour map of the current plot
%   mtexColorMap(hsvColorMap)
%
% Input
%  m - number of colours
%
% Output
%  map - m x 3 matrix of RGB values
%
% See also
% mtexColorMap

%HSV    Hue-saturation-value color map
%   HSV(M) returns an M-by-3 matrix containing an HSV colormap.
%   HSV, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   An HSV colormap varies the hue component of the hue-saturation-value
%   color model.  The colors begin with red, pass through yellow, green,
%   cyan, blue, magenta, and return to red.  The map is particularly
%   useful for displaying periodic functions.  
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(hsv)
%
%   See also GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM, JET,
%   COLORMAP, RGBPLOT, HSV2RGB, RGB2HSV

%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 8-19-92, 2-19-93.
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2005/06/21 19:30:31 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
h = (0:m-1)'/max(m,1);
if isempty(h)
  map = [];
else
  map = hsv2rgb([h ones(m,2)]);
end
