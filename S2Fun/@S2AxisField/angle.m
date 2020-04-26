function S2F = angle(sAF1,sAF2,varargin)
%
% syntax
%  f = angle(sAF,v)
%  f = angle(sAF1,sAF2)
%  f = angle(sAF,sVF)
%
% Input
%  sAF,sAF1,sAF2 - @S2AxisField
%  sVF  - @S2VectorField
%  v    - @vector3d
%
% Output
%  f - @S2FunHarmonic
%

S2F = acos(dot(sAF1,sAF2,varargin{:}));
