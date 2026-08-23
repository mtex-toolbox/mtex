classdef S2VectorField
% an abstract class representing vector fields on the sphere
%
% A spherical vector field assigns a @vector3d to every direction, e.g.
% the gradient of an @S2Fun. Deriving classes only have to implement the
% method eval, plotting and arithmetics are inherited from here.
%
% Derived Classes
%  @S2VectorFieldHarmonic - harmonic series of the three components
%  @S2VectorFieldTri      - values at the nodes of a triangulation
%  @S2VectorFieldHandle   - field given by a function handle
%
% Example
%
%   vF = S2VectorField.polar(vector3d.Z)
%
% See also
% S2Fun S2AxisField

methods

end

methods (Abstract = true)

  f = eval(sF, v, varargin)

end

methods (Sealed = true)
  h = plot(sF,varargin)
end

methods(Static = true)
  v = theta(v);
  v = rho(v);
  v = normal(v);
  
  vF = polar(rRef);
  [t1,t2] = tangential(rRef);
  vF = oneSingularity(rRef);
  vF = sigma(varargin);
  
end

end
