classdef S2FunHarmonic < S2Fun
% a class representing a function on the sphere

properties
  fhat = []; % harmonic coefficients
  s          % symmetry
end

properties (Dependent=true)
  bandwidth;  % maximum harmonic degree / bandwidth
  antipodal;  %
  isReal;
end

methods
  
  function sF = S2FunHarmonic(fhat,varargin)
    % initialize a spherical function
    
    if nargin == 0, return; end

    % convert arbitrary S2Fun or S2Kernel to S2FunHarmonic
    if isa(fhat,'S2FunHarmonic')
      sF.fhat = fhat.fhat;
      sF.s = fhat.s;
      sF = truncate(sF);
      return
    elseif isa(fhat,'S2Fun') || isa(fhat,'function_handle')
      sF = S2FunHarmonic.quadrature(fhat, varargin{:});
      return
    elseif isa(fhat,'S2Kernel')
      psi = fhat;
      bw = psi.bandwidth;
      sF.fhat = zeros((bw+1)^2,1);
      for l = 0:bw
        sF.fhat(l^2+1+l) = 2*sqrt(pi)./sqrt(2*l+1)*psi.A(l+1); 
      end
      sF.s = getClass(varargin,'symmetry',specimenSymmetry);
      return
    end

    % construct S2FunHarmonic from Fourier coefficients
    s = size(fhat);
    bandwidth = ceil(sqrt(s(1))-1); % Make entries to the next polynomial degree
    sF.fhat = [fhat; zeros([(bandwidth+1)^2-size(fhat, 1), s(2:end)])];
    
    sF.antipodal = check_option(varargin,'antipodal');
    
    sF.s = getClass(varargin,'symmetry',specimenSymmetry);

    % truncate zeros
    %sF = sF.truncate;

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
    sF = reshape(sF,numel(sF));
    sF = truncate(sF);
    normF = sum(abs(sF.fhat-sF.even.fhat).^2);
    out = all(sqrt(normF) < 1e-5*norm(sF));
  end
  
  function sF = set.antipodal(sF,value)
    if value, sF = sF.even; end
  end

  function out = get.isReal(sF)
    if sF.bandwidth == 0
      out = isreal(sF.fhat);
      return
    end
    sF = reshape(sF,numel(sF));
    ind = zeros((sF.bandwidth+1)^2,1);
    for l = 0:sF.bandwidth
      ind(l^2+1:(l+1)^2) = (l+1)^2:-1:l^2+1;
    end
    dd = sum(abs(sF.fhat-conj(sF.fhat(ind,:))).^2);
    nF = norm(sF)';
    out = all(sqrt(dd(nF>0)) ./ nF((nF>0)) <1e-4);
  end

  function sF = set.isReal(sF,value)
    if ~value, return; end
    sz = size(sF);
    sF = reshape(sF,prod(sz));
    ind = zeros((sF.bandwidth+1)^2,1);
    for l = 0:sF.bandwidth
      ind(l^2+1:(l+1)^2) = (l+1)^2:-1:l^2+1;
    end
    sF.fhat = 0.5*(sF.fhat+conj(sF.fhat(ind,:)));
    sF=reshape(sF,sz);
  end

  function d = size(sF, varargin)
    d = size(sF.fhat);
    d = d(2:end);
    if isscalar(d), d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end
  end

end

methods (Static = true)
  sF = approximate(f, varargin);
  sF = quadrature(f, varargin);
  sF = adjoint(vec,values,varargin);
  sF = interpolate(v, y, varargin);
  sF = regularize(nodes,y,lambda,varargin);

  function sF = loadobj(sF)
    % called by Matlab when an object is loaded from an .mat file
    % this overloaded method ensures compatibility with older MTEX
    % versions

    if isempty(sF.s), sF.s = specimenSymmetry; end
                  
  end

end

end
