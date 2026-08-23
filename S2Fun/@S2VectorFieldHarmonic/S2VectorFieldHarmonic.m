classdef S2VectorFieldHarmonic < S2VectorField
% a class representing a vector field on the sphere by harmonic series
%
% The three Cartesian components are stored as a 3x1 array of
% @S2FunHarmonic.
%
% Syntax
%   vF = S2VectorFieldHarmonic(sF)
%   vF = S2VectorFieldHarmonic(fun)
%   vF = S2VectorFieldHarmonic(fun,'bandwidth',N)
%
% Input
%  sF  - 3x1 @S2FunHarmonic, the x, y and z component
%  fun - @S2VectorField or @function_handle to be approximated
%
% Output
%  vF - @S2VectorFieldHarmonic
%
% Options
%  bandwidth - maximum harmonic degree
%
% Class Properties
%  sF        - the three components as @S2FunHarmonic
%  x, y, z   - the individual components
%  bandwidth - maximum harmonic degree
%
% Example
%
%   vF = S2VectorFieldHarmonic.quadrature(@(v) cross(v,vector3d.Z))
%
% See also
% S2VectorField S2FunHarmonic

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
    elseif isa(sF,'S2FunHarmonic')
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
  sVF = example(varargin)
  function sVF = normal
    sVF = S2VectorFieldHarmonic.quadrature(@(v) v,'bandwidth',2);
  end
end

end
