classdef ChristoffelTensor < tensor
% class representing the Christoffel tensor of a wave direction
%
% The Christoffel tensor E(n) = n * C * n is the rank 2 tensor a
% @stiffnessTensor C induces for a propagation direction n. Its
% eigenvalues give the elastic wave velocities in that direction, its
% eigenvectors the corresponding polarization directions.
%
% Syntax
%   E = ChristoffelTensor(M,cs)
%
% Input
%  M  - 3x3 matrix
%  cs - crystal @symmetry
%
% Output
%  E - @ChristoffelTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% Example
%
%   fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
%   C = stiffnessTensor.load(fname);
%   E = ChristoffelTensor(C,vector3d.X)
%
% See also
% tensor stiffnessTensor
%

  methods
    function sT = ChristoffelTensor(varargin)

      sT = sT@tensor(varargin{:},'rank',2);
      
    end
  end
  
   
  methods (Static = true)
    function C = load(varargin)
      T = load@tensor(varargin{:});
      C = ChristoffelTensor(T);
    end
  end
end