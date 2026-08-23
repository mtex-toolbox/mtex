classdef stiffnessTensor < tensor
% class representing the elastic stiffness tensor
%
% The stiffness tensor C is the rank 4 tensor relating stress and strain
% by sigma = C : epsilon. It is usually given as a 6x6 Voigt matrix, in
% GPa and without the factor of two of the double convention. The
% constructor warns if the matrix is not symmetric or not positive
% definite.
%
% Syntax
%   C = stiffnessTensor(M,cs)
%   C = stiffnessTensor(M,cs,'unit','GPa')
%
% Input
%  M  - 6x6 Voigt matrix or 3x3x3x3 array
%  cs - crystal @symmetry
%
% Output
%  C - @stiffnessTensor
%
% Options
%  unit - physical unit of the entries, GPa by default
%
% Class Properties
%  M     - the tensor coefficients
%  rank  - always 4
%  CS    - @symmetry the coefficients refer to
%
% Example
%
%   cs = crystalSymmetry('m-3m');
%   C = stiffnessTensor(diag([230 230 230 117 117 117]),cs)
%
% See also
% tensor complianceTensor
%

  methods
    function sT = stiffnessTensor(varargin)

      varargin = set_default_option(varargin,{},'unit','GPa');
      sT = sT@tensor(varargin{:},'rank',4);
      sT.doubleConvention = false;
      
      if ~sT.isSymmetric, warning('Tensor is not symmetric!'); end
      lambda = eig(sT);
      if ~all(lambda(:) > 0), warning('Tensor is not positive definite'); end

    end
  end
  
   
  methods (Static = true)
    function C = load(fname,varargin)
      if ~exist(fname,'file')
        fname = [mtexDataPath filesep 'stiffnessTensor' filesep fname];
      end
      T = load@tensor(fname,varargin{:});
      C = stiffnessTensor(T);
    end
    
    function C = eye(varargin)

      C = stiffnessTensor(tensor.eye(varargin{:},'rank',4));

    end

    % a static method cannot tell which subclass it was called on; zeros, ones
    % and nan have no counterpart here, none of them is a stiffness tensor
    C = rand(varargin);

  end
end