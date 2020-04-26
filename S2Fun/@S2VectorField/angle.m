function S2F = angle(sVF1,sVF2,varargin)
%
% syntax
%  f = angle(sVF,v)
%  f = angle(sVF1,sVF2)
%
% Input
%  sAF,sVF1,sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  f - @S2FunHarmonic
%

S2F = acos(dot(sVF1,sVF2,varargin{:}));
