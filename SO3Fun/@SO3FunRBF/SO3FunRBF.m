classdef SO3FunRBF < SO3Fun
% a class representing radial ODFs by an SO3Kernel function and center orientations
%
% Syntax
%   SO3F = SO3FunRBF(center,psi,weights,c0)
%   SO3F = SO3FunRBF(F)
%
% Input
%  center  - @orientation
%  psi     - @SO3Kernel
%  weights - double
%  c0      - double
%  F       - @SO3Fun
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
    
    function SO3F = SO3FunRBF(center,psi,weights,c0,varargin)
                 
      if nargin == 0, return;end

      if isa(center,'SO3Fun')
        if nargin>=4, varargin = [c0,varargin]; end
        if nargin>=3, varargin = [weights,varargin]; end
        if nargin>=2, varargin = [psi,varargin]; end
        SO3F = SO3FunRBF.approximate(center,varargin{:});
        return
      end
      
      if ~isa(center,'orientation')
        center = orientation(center); 
      end
      SO3F.center  = center;

      if nargin==1
        SO3F.weights = ones(size(center))./length(center);
        return; 
      end
      
      SO3F.psi = psi;
      
      if nargin > 2
        SO3F.weights = reshape(weights,size(center));
      else
        SO3F.weights = ones(size(center)) ./ length(center)./psi.A(1);
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
    [SO3F,resvec] = interpolate(ori,values,varargin)
    SO3F = approximate(v, y, varargin);
    SO3F = example(varargin)
  end
  
end
