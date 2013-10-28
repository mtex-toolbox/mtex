function [ebsd,map] = findByLocation( ebsd, xy )
% select EBSD data by spatial coordinates
%
% Input
%  ebsd - @EBSD
%  xy - list of [x(:) y(:)] coordinates, respectively [x(:) y(:) z(:)]
%
% Output
%  ebsd - @EBSD subset
%
% Example 
%   plotx2east
%   plot(ebsd)
%   p = ginput(1)
%   g = findByLocation(ebsd,p)
%
% See also
% EBSD/findByLocation GrainSet/findByOrientation



if all(isfield(ebsd.options,{'x','y','z'}))
  x_D = get(ebsd,'xyz');
elseif all(isfield(ebsd.options,{'x','y'}))
  x_D = get(ebsd,'xy');
else
  error('mtex:findByLocation','no Spatial Data!');
end

delta = 1.5*mean(sqrt(sum(diff(ebsd.unitCell).^2,2)));

x_Dm = x_D-delta;  x_Dp = x_D+delta;

nd = sparse(length(ebsd),size(xy,1));
dim = size(x_D,2);
for k=1:size(xy,1)
  
  candit = find(all(bsxfun(@le,x_Dm,xy(k,:)) & bsxfun(@ge,x_Dp,xy(k,:)),2));
  dist = sqrt(sum(bsxfun(@minus,x_D(candit,:),xy(k,:)).^2,2));
  [dist i] = min(dist);
  nd(candit(i),k) = 1;
  
end

map = any(nd,2);
ebsd = subSet(ebsd,map);




