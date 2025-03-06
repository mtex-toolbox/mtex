classdef SO3FunRBF < SO3Fun
% a class representing radial ODFs by an SO3Kernel function and center orientations
%
% Syntax
%   SO3F = SO3FunRBF(center,psi,weights,c0)
%
%   SO3F = SO3FunRBF(F)
%   SO3F = SO3FunRBF(F,'kernel',psi,__) % See SO3FunRBF.approximate for options list
%   SO3F = SO3FunRBF(F,'harmonic',__) % See SO3FunRBF.approximate for option list
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
% See also
% SO3FunRBF/approximate

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
    
  function SO3F = SO3FunRBF(center,varargin)
      
    if nargin == 0, return; end
	
  	% convert arbitrary SO3Fun to SO3FunRBF
    if isa(center,'SO3FunRBF') 
      % check input: 'kernel', 'halfwidth', 'SO3Grid', 'resolution'
      psi = get_option(varargin,'kernel');
      hw = get_option(varargin,'halfwidth');
      SO3G = get_option(varargin,'SO3Grid');
      res = get_option(varargin,'resolution');
      SO3F = center;
      if (isempty(psi) || SO3F.psi==psi) && ... 
         (isempty(hw) || (isa(SO3F.psi,'SO3DeLaValleePoussinKernel') && abs(SO3F.psi.halfwidth-hw)<0.25*degree)) && ...
         (isempty(SO3G) || (numel(SO3F.center)==numel(SO3G) && all(reshape(SO3F.center==SO3G,[],1)) )) && ...
         (isempty(res) || (isa(SO3F.center,'SO3Grid') && abs(SO3F.center.resolution-res)<0.25*degree))
        return
      end
    end
    if isa(center,'function_handle') || isa(center,'SO3Fun')
      SO3F = SO3FunRBF.approximate(center,varargin{:});
      return
    end
      
    % get orientation grid
    if ~isa(center,'orientation')
      center = orientation(center);
    end
    SO3F.center = center;
    
    % get kernel
    psi = getClass(varargin,'SO3Kernel');
    if ~isempty(psi), SO3F.psi = psi; end
      
    % get weights and constant part c0
    idw = cellfun(@(x) isnumeric(x) && ( (numel(x)==numel(center)) || (size(x,1)==numel(center)) ),varargin);
    idw = find(idw,1);
    if isempty(idw)
      idc0 = cellfun(@(x) isnumeric(x),varargin);
      if isempty(find(idc0,1))
        c0=0; 
      else
        c0 = varargin{find(idc0,1)};
      end
      weights = ones([numel(center),size(c0)]) ./ numel(center);
    else
      weights = varargin{idw};
      varargin{idw}=[];
      if numel(weights) == length(center)
        weights = weights(:);
      end
      sz = size(weights); sz = sz(2:end);
      if isscalar(sz), sz = [sz,1]; end
      idc0 = cellfun(@(x) isnumeric(x) && all(size(x)==sz) ,varargin);
      if isempty(find(idc0,1))
        c0=zeros(sz); 
      else
        c0 = varargin{find(idc0,1)};
      end
    end
    SO3F.weights = weights;
    SO3F.c0 = c0;
    
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
        ss = size(SO3F);
        SO3F.c0 = subsref(SO3F.c0,s(1));
        
        if isscalar(s(1).subs)
          s(1).subs = [':' s(1).subs];
          SO3F.weights = subsref(SO3F.weights,s(1));
        else
          SO3F.weights = full(SO3F.weights(:,sub2ind(ss, s(1).subs{:})));
        end
        
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

    if ~isa(SO3F,'SO3FunRBF') && ~isempty(b)
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

  function S3F = transpose(S3F)
    S3F.c0 = S3F.c0.';
  end

  function S3F = ctranspose(S3F)
    S3F.c0 = S3F.c0';
  end

end
  
methods (Static = true)
  [SO3F,iter] = approximate(f, varargin);
  [SO3F,iter] = interpolate(v, y, varargin); 
  SO3F = example(varargin)
end
  
end
