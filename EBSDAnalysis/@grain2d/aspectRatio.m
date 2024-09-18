function asp = aspectRatio(grains,varargin)
% aspect ratio = length / width
%
% the aspect ratio is the ratio between the two
% <grain2d.principalComponents.html,principal components> of a grain
%
% Input
%  g - @grain2d
%
% Output
%  asp   - aspect--ratio
%
% See also
% grain2d/principalComponents

[a,b] = principalComponents(grains);
asp = abs(norm(a) ./ norm(b));

% asp2 = diameter(grains).^2 ./ area(grains);
