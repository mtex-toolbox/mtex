function sF = angle(varargin)
% pointwise angle between a vector field and a field or a direction
%
% Syntax
%
%   sF = angle(sVF,sVF2)   % the angle between two fields at every vertex
%   sF = angle(sVF,v)      % the angle to the direction v at every vertex
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