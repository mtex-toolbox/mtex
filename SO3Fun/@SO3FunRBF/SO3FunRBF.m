classdef SO3FunRBF < SO3Fun
% a class representing radial ODFs by an SO3Kernel function and center orientations
%
% Syntax
%   SO3F = SO3FunRBF(center,psi,weights,c0)
%
% Input
%  center  - @orientation
%  psi     - @SO3Kernel
%  weights - double
%  c0      - double
%
% Output
%  SO3F - @SO3FunRBF
%
% Example
%
%   ori = orientation.rand(10);
%   w = rand(10,1); w=w./sum(w);
%   psi = SO3DeLaValleePoussinKernel(10);
%   SO3F = SO3FunRBF(ori,psi,w)
%

  properties
    c0 = 0                           % constant portion
    center = orientation             % center of the components
    psi = SO3DeLaValleePoussinKernel % shape of the components
    weights = []                     % coefficients
  end

  properties (Dependent = true)
    bandwidth % harmonic degree
    antipodal
    SLeft
    SRight
  end
  
  methods
    
    function SO3F = SO3FunRBF(center,psi,weights,c0)
                 
      if nargin == 0, return;end
      
      if ~isa(center,'orientation'), center = orientation(center); end
      SO3F.center  = center;

      if nargin==1
        SO3F.weights = ones(size(center))./length(center);
        return; 
      end
      
      SO3F.psi = psi;
      
      if nargin > 2
        SO3F.weights = reshape(weights,size(center));
      else
        SO3F.weights = ones(size(center)) ./ length(center);
      end
      
      if nargin > 3, SO3F.c0 = c0; end
      
    end

    
    function SO3F = set.SRight(SO3F,S)
      SO3F.center.CS = S;
    end
    
    function S = get.SRight(SO3F)
      try
        S = SO3F.center.CS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.center.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      try
        S = SO3F.center.SS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.antipodal(SO3F,antipodal)
      SO3F.center.antipodal = antipodal;
    end
        
    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.center.antipodal;
      catch
        antipodal = false;
      end
    end
    
    function L = get.bandwidth(SO3F)
      if isempty(SO3F.weights)
        L = 0;
      else
        L= SO3F.psi.bandwidth;        
      end
    end
    
    function SO3F = set.bandwidth(SO3F,L)
      SO3F.psi.bandwidth = L;
    end
    
  end
  
  methods (Static = true)
    
    SO3F = example(varargin)

  end
  
end
