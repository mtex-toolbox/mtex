classdef deformationGradientTensor < tensor
  % class representing a deformation gradient tensor
  % 
  % The deformation gradient F contains the full information about the
  % local rotation and deformation of the material. It also shows, for
  % example, how a small line segment in the undeformed body, dX, is
  % rotated and stretched into a line segment in the deformed body, dx,
  % since dx = F dX. As F is volume preserving this implies that det F = 1.
  %
  % Syntax
  %   F = deformationGradientTensor(M)
  %   F = deformationGradientTensor.uniaxial(d,rate)
  %   F = deformationGradientTensor.simpleShear(d,n,e)
  %   F = deformationGradientTensor.pureShear(exp,compr,lambda)
  %
  % Input
  %  M           - 3x3 matrix
  %  d, n        - @vector3d
  %  rate, e     - amount of deformation
  %  exp, compr  - extension and compression direction, @vector3d
  %  lambda      - stretch
  %
  % Output
  %  F - @deformationGradientTensor
  %
  % Class Properties
  %  M    - the tensor coefficients
  %  rank - always 2
  %  CS   - @symmetry the coefficients refer to
  %
  % Example
  %
  %   F = deformationGradientTensor.simpleShear(vector3d.X,vector3d.Z,0.2)
  %
  % See also
  % tensor velocityGradientTensor strainTensor
  %

  methods
    function F = deformationGradientTensor(varargin)
      F = F@tensor(varargin{:},'rank',2);
    end       
  end

  methods (Static = true)
  
    F = pureShear(exp,compr,lambda)
    F = simpleShear(d,n,e)
    F = uniaxial(d,rate);
    
  end
  
  
end

