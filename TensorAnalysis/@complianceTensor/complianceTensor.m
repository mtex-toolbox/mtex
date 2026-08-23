classdef complianceTensor < tensor
% class representing the elastic compliance tensor
%
% The compliance tensor S is the inverse of the @stiffnessTensor and
% relates strain and stress by epsilon = S : sigma. It is given in 1/GPa
% and, unlike the stiffness tensor, in the double convention - the off
% diagonal entries of its Voigt matrix carry a factor of two.
%
% Syntax
%   S = complianceTensor(M,cs)
%
% Input
%  M  - 6x6 Voigt matrix or 3x3x3x3 array
%  cs - crystal @symmetry
%
% Output
%  S - @complianceTensor
%
% Options
%  unit - physical unit of the entries, 1/GPa by default
%
% Class Properties
%  M     - the tensor coefficients
%  rank  - always 4
%  CS    - @symmetry the coefficients refer to
%
% Example
%
%   fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
%   S = inv(stiffnessTensor.load(fname))
%
% See also
% tensor stiffnessTensor
%

  methods
    function sT = complianceTensor(varargin)
      
      varargin = set_default_option(varargin,{},'unit','1/GPa','doubleConvention');
      sT = sT@tensor(varargin{:},'rank',4);

      if ~sT.isSymmetric, warning('Tensor is not symmetric!'); end
      lambda = eig(sT);
      if ~all(lambda(:) > 0), warning('Tensor is not positive definite'); end

    end
  end
  
   
  methods (Static = true)
    function C = load(varargin)
      T = load@tensor(varargin{:});
      C = complianceTensor(T);
    end
    
    function C = eye(varargin)

      C = complianceTensor(tensor.eye(varargin{:},'rank',4));

    end

    % see the note in @stiffnessTensor
    C = rand(varargin);

  end
end