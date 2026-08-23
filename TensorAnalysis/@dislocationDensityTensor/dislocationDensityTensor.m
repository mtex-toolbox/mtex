classdef dislocationDensityTensor < tensor
% class representing the dislocation density or Nye tensor
%
% The dislocation density tensor is the rank 2 tensor obtained from the
% @curvatureTensor of an orientation field. Fitting it against a list of
% @dislocationSystem gives the densities of geometrically necessary
% dislocations.
%
% Syntax
%   alpha = dislocationDensityTensor(M,cs)
%   alpha = dislocationDensityTensor(kappa)
%
% Input
%  M     - 3x3 matrix
%  cs    - crystal @symmetry
%  kappa - @curvatureTensor
%
% Output
%  alpha - @dislocationDensityTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% See also
% tensor curvatureTensor dislocationSystem
%

  methods
    function alpha = dislocationDensityTensor(varargin)
      alpha = alpha@tensor(varargin{:},'rank',2);
    end
  end
  
end