function sF = angle(varargin)
% pointwise angle between an axis field and another axis field or a direction
%
% Syntax
%
%   sF = angle(sVF,sVF2) % angle between two axis fields
%   sF = angle(sVF,v)    % angle to a fixed direction
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