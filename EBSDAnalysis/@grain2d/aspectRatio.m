function asp = aspectRatio(grains,varargin)
% calculates the aspectratio of grain
%
% the aspect ratio is the ratio between the two
% <grain2d.principalcomponents.html,principal componentes> of a grain
%
% Input
%  g - @grain2d
%
% Output
%  asp   - aspect--ratio
%
% See also
% grain2d/principalcomponents

[ev,ew] = principalComponents(grains);
asp = abs(reshape(ew(1,1,:)./ew(2,2,:),[],1));

% asp2 = diameter(grains).^2 ./ area(grains);
