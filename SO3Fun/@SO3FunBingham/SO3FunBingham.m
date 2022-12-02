classdef SO3FunBingham < SO3Fun
% a class representing BinghamODFs
%
% Syntax
%   SO3F = SO3FunBingham(kappa,A,cs)
%
% Input
%  kappa - vector (shape parameter)
%  A     - orthogonal 4x4 matrix
%  cs    - @Symmetry
%
% Output
%  SO3F - @SO3FunBingham
%
% Example
%   
%   cs = crystalSymmetry('1');
%   kappa = [100 90 80 0];
%   U     = eye(4);
%   f = BinghamODF(kappa,U,cs)
%

  properties
    A
    kappa = [1,0,0,0];
    % TODO: antipodal wird weder erkannt noch gesetzt/verwendet
    antipodal = false;
    weight = 1;
  end
 
  properties (Dependent = true)    
    bandwidth % harmonic degree
    SLeft
    SRight
  end
  
  properties (Hidden = true)
    C0 % normalization constant
  end
  
  methods
    
    function SO3F = SO3FunBingham(kappa,A,cs)
        
      if nargin == 0, return;end
      
      if isnumeric(A), A = orientation(quaternion(A)); end

      if nargin == 3, A.CS = cs; end

      SO3F.kappa = kappa(:);
      SO3F.A = A;

    end
    
    
    function SO3F = set.kappa(SO3F,kappa)
      SO3F.C0 = mhyper(kappa);
      SO3F.kappa = kappa;      
    end
    
    function SO3F = set.SRight(SO3F,S)
      SO3F.A.CS = S;
    end
    
    function S = get.SRight(SO3F)
      S = SO3F.A.CS;      
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.A.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      S = SO3F.A.SS;
    end
  
    function L = get.bandwidth(SO3F) %#ok<MANU>
      L = inf;
    end
    
    function SO3F = set.bandwidth(SO3F,~)      
    end

  end

  methods (Static = true)
  
    SO3F = example(varargin)
    
  end
  
end
