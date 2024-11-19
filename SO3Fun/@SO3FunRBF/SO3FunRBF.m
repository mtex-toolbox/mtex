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
    
    if nargin >= 2, SO3F.psi = psi; end
      
    if nargin > 2
      SO3F.weights = reshape(weights,length(SO3F.center),[]);
    else
      weights = 1;
      SO3F.weights = ones(numel(center),1) ./ numel(center);
    end
    
    if nargin > 3
      SO3F.c0 = c0;
    else
      s = [size(weights) 1];
      SO3F.c0 = zeros(s(2:end));
    end
      
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
    
  function s = size(SO3F,varargin)
    s = size(SO3F.c0,varargin{:});
  end

  function n = numel(SO3F)
    n = numel(SO3F.c0);
  end
  
  function l = length(SO3F), l = numel(SO3F); end

  function n = numArgumentsFromSubscript(varargin), n = 0; end
  
  function e = end(SO3F,i,n)
    if n==1
      e = numel(SO3F);
    else
      e = size(SO3F,i+1);
    end
  end
  
  function varargout = subsref(SO3F,s)
    switch s(1).type
      case '()'
        SO3F.c0 = subsref(SO3F.c0,s(1));
        s(1).subs = [':' s(1).subs];
        SO3F.weights = subsref(SO3F.weights,s(1));
        
        if numel(s)>1
          [varargout{1:nargout}] = builtin('subsref',SO3F,s(2:end));
        else
          varargout{1} = SO3F;
        end
      otherwise
        [varargout{1:nargout}] = builtin('subsref',SO3F,s);
    end
  end

  function SO3F = subsasgn(SO3F, s, b)
    % overloads subsasgn

    if ~isa(SO3F,'SO3FunHarmonic') && ~isempty(b)
      SO3F = b;
      SO3F.weights = [];
      SO3F.c0 = [];
    end
    
    switch s(1).type
      case '()'
      
        if numel(s) > 1, b =  builtin('subsasgn', subsref(SO3F,s(1)), s(2:end), b); end
    
        sExt = s(1); sExt.subs = [':' sExt.subs];
    
        % remove functions
        if isempty(b)
          SO3F.c0 = subsasgn(SO3F.c0,s(1),b);          
          SO3F.weights = subsasgn(SO3F.weights,sExt,b);
          return
        end
    
        ensureCompatibleSymmetries(SO3F,b);
            
        SO3F.c0 = subsasgn(SO3F.c0,s(1),b.c0);
        SO3F.weights = subsasgn(SO3F.weights,sExt, b.weights);
        
      otherwise
    
        SO3F =  builtin('subsasgn',SO3F,s,b);
    end
  end

  function S3F = reshape(S3F,varargin)
    S3F.c0 = reshape(S3F.c0, varargin{:});
  end


end
  
methods (Static = true)
    
  SO3F = example(varargin)

end
  
end
