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
    if isa(fhat,'S2FunHarmonic')       
      sF.fhat = fhat.fhat;
    else
      s = size(fhat);
      bandwidth = ceil(sqrt(s(1))-1); % Make entries to the next polynomial degree
      sF.fhat = [fhat; zeros([(bandwidth+1)^2-size(fhat, 1), s(2:end)])];
    end
    
  end
  
  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
  function bandwidth = get.bandwidth(sF)
    bandwidth = sqrt(size(sF.fhat, 1)) - 1;
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
    sF = truncate(sF);
    out = (prod(norm(sF - sF.even) < 1e-5*norm(sF)) > 0);
  end
  
  function sF = set.antipodal(sF,value)
    if value, sF = sF.even; end
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

end

methods (Static = true)
  sF = approximation(v, y, varargin);
  sF = quadrature(f, varargin);
  sF = regularisation(nodes,y,lambda,varargin);
end

end
