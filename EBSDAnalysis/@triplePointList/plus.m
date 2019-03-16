function tP = plus(tP,xy)
% shift triple points in x/y direction
%
% Syntax
%
%   % shift in x direction
%   tP = gB + [100,0] 
%
% Input
%  tP - @triplePointList
%  xy - x and y coordinates of the shift
%
% Output
%  tP - @triplePointList

if isa(xy,'triplPointList'), [xy,tP] = deal(tP,xy); end
if isa(xy,'vector3d'), xy = [xy.x,xy.y]; end

tP.V = tP.V + repmat(xy,size(tP.V,1),1);
