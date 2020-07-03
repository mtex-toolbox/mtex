function sF = angle(varargin)
%
% Syntax
%   sVF = angle(sVF,sVF2)
%   sVF = angle(sVF,v)
%
% Input
%  sVF  - @S2AxisFieldTri
%  sVF2 - @S2AxisField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri
%
sF = dot(varargin{:});
sF.values = acos(min(1,max(-1,sF.values)));