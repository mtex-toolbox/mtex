function sF = dot(sVF, a, varargin)
% pointwise inner product of a vector field with a vector field or a vector
%
% Syntax
%
%   sF = dot(sVF,sVF2)   % inner product with a field
%   sF = dot(sVF,v)      % inner product with a fixed vector
%
% Input
%  sVF  - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri

% first should be S2VectorFieldTri
if ~isa(sVF,'S2VectorFieldTri'), [sVF,a] = deal(a,sVF); end

if isa(a,'vector3d')
  sF = S2FunTri(sVF.tri, dot(sVF.values, a, varargin{:}));
elseif isa(a,'S2AxisFieldTri') || isa(a,'S2VectorFieldTri')
  sF = S2FunTri(sVF.tri, dot(sVF.values, b.values, varargin{:}));
else
   sF = S2FunTri(sVF.tri, dot(sVF.values, b.eval(sVF.vertices), varargin{:}));
end

end
