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
    cutoff = eps; 
    ii = 0;
    while sum(abs(fhat((M-ii)^2+1:(M+1)^2))) <= cutoff && M > 0
      ii = ii+1; 
    end
    sF.fhat = fhat(1:(M+1-ii)^2);
    
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
