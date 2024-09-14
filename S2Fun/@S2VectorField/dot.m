function sF = dot(sVF1, sVF2, varargin)
% pointwise inner product
%
% Syntax
%   d = dot(sVF1, sVF2)
%   d = dot(v, sVF2)
%   d = dot(sVF1, v)
%
% Input
%   sVF1, sVF2 - @S2VectorField
%   v - @vector3d
%
% Output
%   sF - @S2FunHandle
%

if isa(sVF2, 'vector3d')
  f = @(v) dot(sVF1.eval(v), sVF2);
elseif isa(sVF1, 'vector3d')
  f = @(v) dot(sVF1, sVF2.eval(v)); 
else
  f = @(v) dot(sVF1.eval(v), sVF2.eval(v));  
end

sF = S2FunHandle(f);

end
