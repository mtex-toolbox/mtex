classdef sphFunHarmonic < sphFun
% a class representing a function on the sphere

properties
  fhat = [] % harmonic coefficients
end

properties (Dependent=true)
  M          % maximum harmonic degree / bandwidth
  antipodal  %
end

methods
  
  function sF = sphFunHarmonic(fhat)
    % initialize a spherical function
    
    if nargin == 0, return; end
  
    fhat = fhat(:);
    M = ceil(sqrt(length(fhat))-1); % make (M+1)^2 entries
    fhat = [fhat; zeros((M+1)^2-length(fhat), 1)];

    % truncate neglectable coefficients
    % this includes a bit of regularisation 
    m = 1+repelem(0:M,2*(0:M)+1);
    fh = fhat ./  reshape(m.^2,[],1);
    fh = sqrt(accumarray(m.',abs(fh).^2));
    cutoff = max(fh) * 1e-8; 
    M = find(fh > cutoff,1,'last')-1;
    if isempty(M) || ( M < 0 ), M = 0; end
    sF.fhat = fhat(1:(M+1)^2);
    
  end
  
  function M = get.M(sF)
    M = sqrt(length(sF.fhat))-1;
  end
  
  function sF = set.M(sF,M)
    sF.fhat((M+1)^2+1:end) = [];
  end
  
  function out = get.antipodal(sF)
    
    out = norm(sF - sF.even) < 1e-5;
    
  end
  
  function sF = set.antipodal(sF,value)
    
    if value, sF = sF.even; end
    
  end
  
  
  function fhat = get_fhat(sF, m, l)
    if abs(l) <= m && 0 <= m && m <= sF.M
      fhat = sF.fhat(m*(m+1)+l+1);
    else
      fhat = 0;
    end
  end
  
end

methods (Static = true)
  sF = approximation(v, y, varargin);
  sF = quadrature(f, varargin);
end

end
