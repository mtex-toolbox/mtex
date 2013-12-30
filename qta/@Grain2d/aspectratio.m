function asp = aspectratio(grains,varargin)
% calculates the aspectratio of grain
%
% the aspect ratio is the ratio between the two
% [[GrainSet.principalcomponents.html,principal componentes]] of a grain
%
%% Input
%  p - @Grain2d
%
%% Output
%  asp   - aspect--ratio
%
%% See also
% GrainSet/principalcomponents

[ev,ew] = principalcomponents(grains);
asp = abs(reshape(ew(1,1,:)./ew(2,2,:),[],1));

% asp2 = diameter(grains).^2 ./ area(grains);
