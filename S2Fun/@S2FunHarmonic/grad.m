function sVF = grad(sF, varargin)
% calculates the gradient of a spherical harmonic
%
% Syntax
%   sVF = grad(sF) % returns the gradient as a spherical vector field 
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

sF = [sF.drho; sF.dthetasin];

if nargin > 1 && isa(varargin{1},'vector3d')
  
  sVF = localGrad(varargin{1});

elseif check_option(varargin,'lazy')

  sVF = S2VectorFieldHandle(@(v) localGrad(v));

else

  sVF = S2VectorFieldHarmonic.quadrature(@(v) localGrad(v),'bandwidth',sF.bandwidth);
  

  %sF = [sF.drho; sF.dtheta]; sVF = S2VectorFieldHarmonic(sF);

end

  function g = localGrad(v)
    
    gg = sF.eval(v);
    [th,rh] = polar(v);
    
    th = min(pi-eps,max(eps,th));

    x = gg(:,2) .* cos(rh) .* cot(th) - gg(:,1) .* sin(rh) ./ sin(th);
    y = gg(:,2) .* sin(rh) .* cot(th) + gg(:,1) .* cos(rh) ./ sin(th);
    z = -gg(:,2);

    g = vector3d(x,y,z);
  
    %sVF = ...
    %  y(:, 1) ./ sin(v.theta) .* S2VectorField.rho(v)+ ...
    %  y(:, 2) ./ sin(v.theta) .* S2VectorField.theta(v);

    %g(isnan(g)) = vector3d([0 0 0]);

  end

end
