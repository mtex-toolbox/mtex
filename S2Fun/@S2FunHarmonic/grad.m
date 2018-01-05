function sVF = grad(sF, varargin) % gradient
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

if nargin == 3
  Gth = varargin{2};
  Grh = varargin{1};
else
  Gth = sF.dtheta;
  Grh = sF.drho;
end

f = @(v) ...
  Gth.eval(v)./(sin(v.theta).^2).*S2VectorField.rho(v)+ ...
  Grh.eval(v).*S2VectorField.theta(v);
%                       ^
%                       |
%              from the metrix tensor

sVF = S2VectorFieldHarmonic.quadrature(f);

end
