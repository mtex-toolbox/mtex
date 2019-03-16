function ebsd = plus(ebsd,xy)
% shift ebsd in x/y direction
%
% Syntax
%
%   % shift in x direction
%   ebsd = ebsd + [100,0] 
%
% Input
%  ebsd - @EBSD
%  xy - x and y coordinates of the shift
%
% Output
%  ebsd - @EBSD

if isa(xy,'EBSD'), [xy,ebsd] = deal(ebsd,xy); end
if isa(xy,'vector3d'), xy = [xy.x,xy.y]; end

ebsd.prop.x = ebsd.prop.x + repmat(xy(:,1),size(ebsd.prop.x,1),1);
ebsd.prop.y = ebsd.prop.y + repmat(xy(:,2),size(ebsd.prop.y,1),1);