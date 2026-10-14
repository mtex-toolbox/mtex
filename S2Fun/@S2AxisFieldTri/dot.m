function sF = dot(sVF, a, varargin)
% pointwise inner product of an axis field with a field or a direction
%
% Syntax
%
%   sF = dot(sVF,sVF2)   % the inner product of two fields at every vertex
%   sF = dot(sVF,v)      % the inner product with the direction v at every vertex
%
% Input
%  sVF  - @S2AxisFieldTri
%  sVF2 - @S2AxisField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri
%

% first should be S2VectorFieldTri
if ~isa(sVF,'S2AxisFieldTri'), [sVF,a] = deal(a,sVF); end

if isa(a,'vector3d')
  sF = S2FunTri(sVF.tri, dot(sVF.values, a, varargin{:}));
elseif isa(a,'S2AxisFieldTri') || isa(a,'S2VectorFieldTri')
  sF = S2FunTri(sVF.tri, dot(sVF.values, a.values, varargin{:}));
else
   sF = S2FunTri(sVF.tri, dot(sVF.values, a.eval(sVF.vertices), varargin{:}));
end

end
