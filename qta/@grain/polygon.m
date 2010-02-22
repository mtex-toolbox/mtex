function p = polygon(grains,varargin)
% returns the polygon of grains as struct
%
%% Input
%  grains - @grain
%
%% Output
%  p    - @polygon
%
% p = grains.polygon;

n = numel(grains);
parts = [0:5000:n-1 n];  % faster as at once
% 
p = repmat(polygon,size(grains));
for k=1:length(parts)-1
%   
  ndx = parts(k)+1:parts(k+1);
  p(ndx) = horzcat(grains(ndx).polygon);
%  
end