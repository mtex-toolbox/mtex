function tP = minus(tP,xy)
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

tP = tP + (-xy);