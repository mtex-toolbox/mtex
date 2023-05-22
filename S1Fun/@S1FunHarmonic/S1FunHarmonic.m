classdef S1FunHarmonic
% a class representing a function on the sphere

properties
  fhat = []; % harmonic coefficients
end

properties (Dependent=true)
  bandwidth  % maximum harmonic degree / bandwidth
  antipodal  %
end

methods
  
  function sF = S1FunHarmonic(fhat, varargin)
    % initialize a spherical function
    
    if nargin == 0, return; end
    if isa(fhat,'S1FunHarmonic')       
      sF.fhat = fhat.fhat;
    else
      sF.fhat = fhat;
    end
    
  end
  
  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
  function bandwidth = get.bandwidth(sF)
    bandwidth = size(sF.fhat, 1)/2 - 1;
  end
  
  function sF = set.bandwidth(sF, bw)
    
    bwOld = sF.bandwidth;
    if bw < bwOld % reduce bandwidth
      sF.fhat((bw+1)^2+1:end,:) = [];
    else % add some zeros
      sF.fhat = [sF.fhat ; zeros([(bw+1)^2-(bwOld+1)^2,size(sF)])];
    end
  end
  
  function out = get.antipodal(sF)
    out = norm(sF.fhat(1+rem(sF.bandwidth,2):2:end)) < 1e-5*norm(sF.fhat);
  end
  
  function sF = set.antipodal(sF,value)
    %if value, sF = sF.even; end
    if value
      sF.fhat(1+rem(sF.bandwidth,2):2:end) = 0;
    end
  end

  function d = size(sF, varargin)
    d = size(sF.fhat);
    d = d(2:end);
    if length(d) == 1, d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end
  end

  function n = numel(sF)
    n = prod(size(sF)); %#ok<PSIZE>
  end

  function fun = uminus(fun)

    fun.fhat = -fun.fhat;

  end


end

methods (Static = true)
  sF = approximation(v, y, varargin);
  sF = quadrature(f, varargin);
end

end
