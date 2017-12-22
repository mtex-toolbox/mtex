classdef S2FunHarmonic < S2Fun
% a class representing a function on the sphere

properties
  fhat = []; % harmonic coefficients
end

properties (Dependent=true)
  bandwidth;  % maximum harmonic degree / bandwidth
  antipodal;  %
end

methods
  
  function sF = S2FunHarmonic(fhat)
    % initialize a spherical function
    
    if nargin == 0, return; end
  
    bandwidth = ceil(sqrt(size(fhat, 1))-1); % make (bandwidth+1)^2 entries
    sF.fhat = [fhat; zeros((bandwidth+1)^2-size(fhat, 1), size(fhat, 2))];

    sF = sF.truncate;

  end
  
  function bandwidth = get.bandwidth(sF)
    bandwidth = sqrt(size(sF.fhat, 1))-1;
  end
  
  function sF = set.bandwidth(sF, bandwidth)
    sF.fhat((bandwidth+1)^2+1:end) = [];
  end
  
  function out = get.antipodal(sF)
    out = norm(sF - sF.even) < 1e-5;
  end
  
  function sF = set.antipodal(sF,value)
    if value, sF = sF.even; end
  end

  function d = size(sF)
    d = [1 size(sF.fhat, 2)];
  end

  function n = numel(sF)
    n = prod(size(sF));
  end

end

methods (Static = true)
  sF = approximation(v, y, varargin);
  sF = quadrature(f, varargin);
end

end
