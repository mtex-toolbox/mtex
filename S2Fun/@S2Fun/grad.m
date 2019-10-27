function sVF = grad(sF, varargin)
% gradient of a spherical function
%
% Syntax
%   sVF = grad(sF)  % returns the gradient as a spherical vector field 
%   g = grad(sF, v) % return the gradient in point v as vector3d
%
% Input
%  sF - @S2FunHarmonic
%  v - @vector3d
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%    g - @vector3d
%


if nargin > 1
  
  delta = 0.1*degree;
  
  N = varargin{1};   % normal direction
  t1 = perp(N);      % first tangential vector
  t2 = normalize(cross(N,t1));  % second tangential vector
  
  % the exponential map on the sphere
  v2 = rotation.byAxisAngle(t1,-delta) .* N;
  v1 = rotation.byAxisAngle(t2,delta) .* N;
  
  sFN = sF.eval(N);
    
  sVF = ((sF.eval(v1)-sFN) .* t1 + (sF.eval(v2)-sFN) .* t2) ./ delta;
  
else
  sVF = S2VectorFieldHarmonic.quadrature(@(v) grad(sF,v));
end

end
