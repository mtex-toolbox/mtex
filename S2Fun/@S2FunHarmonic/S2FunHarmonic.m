classdef S2FunHarmonic < S2Fun
% a class representing a function on the sphere

properties
  fhat = []; % harmonic coefficients
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
      % the resolved frame, so casting a symmetrised function to a plain
      % harmonic one keeps its crystal frame and with it the convention
      sF.framePrivate = fhat.frame;
      sF = truncate(sF);

    elseif isa(fhat, 'S2FunMLS')

      f_hat = calcFourier(fhat, varargin{:});
      sF.fhat = f_hat;
      sF.framePrivate = fhat.frame;

    elseif isa(fhat,'S2Fun') || isa(fhat,'function_handle')

      sF = S2FunHarmonic.quadrature(fhat, varargin{:});

    elseif isa(fhat,'S2Kernel')

      psi = fhat;
      bw = psi.bandwidth;
      sF.fhat = zeros((bw+1)^2,1);
      for l = 0:bw
        sF.fhat(l^2+1+l) = 2*sqrt(pi)./sqrt(2*l+1)*psi.A(l+1);
      end
      sF.framePrivate = S2Fun.extractFrame(varargin{:});

    else % construct S2FunHarmonic from Fourier coefficients

      s = size(fhat);
      bandwidth = ceil(sqrt(s(1))-1); % Make entries to the next polynomial degree
      sF.fhat = [fhat; zeros([(bandwidth+1)^2-size(fhat, 1), s(2:end)])];

      sF.antipodal = check_option(varargin,'antipodal');

      sF.framePrivate = S2Fun.extractFrame(varargin{:});

      % truncate zeros
      %sF = sF.truncate;
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
    sF = reshape(sF,numel(sF));
    sF = truncate(sF);
    normF = sum(abs(sF.fhat-sF.even.fhat).^2);
    out = all(all(sqrt(normF) < 1e-5*norm(sF)));
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
    sF = reshape(sF,sz);
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
  sF = adjointNFSFT(vec,values,varargin);
  [sF,lsqrParameters] = interpolate(v, y, varargin);
  sF = regularize(nodes,y,lambda,varargin);
  sF = example(varargin);
  

  function sF = loadobj(s)
    % called by Matlab when an object is loaded from an .mat file
    % this overloaded method ensures compatibility with older MTEX
    % versions

    if isa(s,'S2FunHarmonic')
      sF = s;
      if ~isempty(sF.framePrivate)
        sF.framePrivate = referenceFrame.reintern(sF.framePrivate);
      end
      return
    end

    % a pre-frame file arrives as a struct because the property s is
    % gone - rebuild and take the frame from the stored symmetry or a
    % stored convention (only frames carry conventions now)
    sF = S2FunHarmonic(s.fhat);
    if isfield(s,'framePrivate') && ~isempty(s.framePrivate)
      sF.framePrivate = referenceFrame.reintern(s.framePrivate);
    elseif isfield(s,'s') && isa(s.s,'symmetry')
      sF.framePrivate = s.s.frame;
    elseif isfield(s,'how2plotPrivate') && ~isempty(s.how2plotPrivate)
      % a pre-frame file stored a bare convention - give it a frame
      sF.framePrivate = referenceFrame.reintern( ...
        specimenSymmetry.frameFor(s.how2plotPrivate));
    end

  end

end

end
