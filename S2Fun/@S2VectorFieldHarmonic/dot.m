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
% Options
%   M - degree of the spherical harmonic
%
% Output
%   sF - @S2Fun

if isa(sVF2, 'vector3d')
  
  sF = sVF1.sF;
  sF.fhat = sum(sF.fhat .* repmat(squeeze(double(sVF2)).',size(sF.fhat,1),1),2);  
 
  if sVF2.antipodal
    sF = abs(sF);
  end
  
else
  
  f = @(v) dot(sVF1.eval(v), sVF2.eval(v));
  sF = S2FunHarmonic.quadrature(f, varargin{:});

end
end
