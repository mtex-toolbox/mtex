function asp = aspectRatio(grains,varargin)
% aspectratio = length / width
%
% the aspect ratio is the ratio between the two
% <grain2d.principalComponents.html,principal componentes> of a grain
%
% Input
%  g - @grain2d
%
% Output
%  asp   - aspect--ratio
%
% See also
% grain2d/principalcomponents

[~,a,b] = principalComponents(grains);
asp = abs(a ./ b);

% asp2 = diameter(grains).^2 ./ area(grains);
