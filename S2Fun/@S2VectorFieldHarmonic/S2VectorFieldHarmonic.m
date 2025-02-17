classdef S2VectorFieldHarmonic < S2VectorField
% a class representing a function on the sphere

properties
  sF
end

properties(Dependent = true)
  x
  y
  z
  bandwidth
end

methods

  function sVF = S2VectorFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    if isa(sF,'S2VectorFieldHarmonic')
      sVF = sF;
      return
    elseif isa(sF,'S2VectorField') || (isa(sF,'function_handle') && isa(sF(zvector),'vector3d'))
      sVF = S2VectorFieldHarmonic.quadrature(sF,varargin{:});
      return
    elseif isa(fhat,'S2FunHarmonic')
      % do not truncate
    elseif isa(sF,'S2Fun') || (isa(sF,'function_handle') && isa(sF(zvector),'double'))
      sF = S2FunHarmonic(sF,varargin{:});
    end

    sVF.sF = sF(:);
    
  end

  function bw = get.bandwidth(sVF), bw = sVF.sF.bandwidth; end
  function sVF = set.bandwidth(sVF,bw), sVF.sF.bandwidth = bw; end
  function x = get.x(sVF), x = sVF.sF(1); end
  function y = get.y(sVF), y = sVF.sF(2); end
  function z = get.z(sVF), z = sVF.sF(3); end
  function sVF = set.x(sVF, x), sVF.sF(1) = x; end
  function sVF = set.y(sVF, y), sVF.sF(2) = y; end
  function sVF = set.z(sVF, z), sVF.sF(3) = z; end

end

methods(Static = true)
  sVF = quadrature(f, varargin)
  sVF = approximate(f, varargin)
  sVF = interpolate(v,y, varargin)
  function sVF = normal
    sVF = S2VectorFieldHarmonic.quadrature(@(v) v,'bandwidth',2);
  end
end

end
