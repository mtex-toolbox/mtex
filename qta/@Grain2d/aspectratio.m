function asp = aspectratio(grains,varargin)
% calculates the aspectratio of grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  asp   - aspect--ratio
%

[ev,ew] = principalcomponents(grains);
asp = abs(reshape(ew(1,1,:)./ew(2,2,:),[],1));

% asp2 = diameter(grains).^2 ./ area(grains);
