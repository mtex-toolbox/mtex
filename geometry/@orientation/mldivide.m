function r = mldivide(a,b)
% o \ v 
%
% Syntax
%   h = o \ r
%
% Input
%  o - @orientation
%  r - @vector3d
%
% Output
%  h - @Miller
%


r = inv(a) * b; %#ok<MINV>
