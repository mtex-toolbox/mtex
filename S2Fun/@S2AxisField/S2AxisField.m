classdef S2AxisField
% an abstract class representing axis fields on the sphere
%
% An axis field is a vector field that is defined only up to sign, e.g. a
% field of principal stress or strain directions. Deriving classes only
% have to implement the method eval.
%
% Derived Classes
%  @S2AxisFieldHarmonic - harmonic series of the outer product v*v'
%  @S2AxisFieldTri      - values at the nodes of a triangulation
%
% See also
% S2VectorField S2Fun

methods

  function AF = S2AxisField(varargin)
  end
  
end

end
