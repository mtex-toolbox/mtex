function sF = angle(varargin)
%
% Syntax
%   sVF = angle(sVF,sVF2)
%   sVF = angle(sVF,v)
%
% Input
%  sVF  - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri
%
sF = dot(varargin{:});
sF.values = acos(sF.values);