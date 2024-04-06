classdef S1FunHarmonic < S1Fun
% a class representing a function on the sphere

properties
  fhat = []; % harmonic coefficients
end

properties (Dependent=true)
  bandwidth  % maximum harmonic degree / bandwidth
  antipodal  %
  isReal
end

methods
  % TODO: rational bandwidth are possible
  
  function sF = S1FunHarmonic(fhat, varargin)
    % initialize a spherical function
    
    if nargin == 0, return; end
    if isa(fhat,'S1FunHarmonic')       
      sF.fhat = fhat.fhat;
      return
    end
    
    sF.fhat = fhat;
    
    % extend entries to full harmonic degree
    if size(fhat,1)>=2 && iseven(size(fhat,1))
      error(['The Fourier coefficients run from -N to N. Hence they ' ...
        'should be an odd number.'])
    end

    if check_option(varargin,'bandwidth')
      sF.bandwidth = get_option(varargin,'bandwidth');
    end

    sF.antipodal = check_option(varargin,'antipodal');
    
%     % truncate zeros
%     N = sF.bandwidth;
%     p = flip(abs(sF.fhat(1:N,:))).^2 + abs(sF.fhat(N+2:end,:)).^2;
%     p = [abs(sF.fhat(N+1,:));sqrt(p)];
%     A = reshape(p,size(p,1),prod(size(sF)));
%     sF.bandwidth = max([0,find(sum(A,2) > 1e-15,1,'last')-1]);

  end
  
  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
  function bandwidth = get.bandwidth(sF)
    bandwidth = (size(sF.fhat, 1) - 1)/2;
  end
  
  function sF = set.bandwidth(sF, bw)
    bwOld = sF.bandwidth;
    if bw < bwOld % reduce bandwidth
      sF.fhat(bwOld+1+(bw+1:bwOld),:) = [];
      sF.fhat(bwOld+1-(bw+1:bwOld),:) = [];
    else % add some zeros
      z = zeros([(bw-bwOld),size(sF)]);
      sF.fhat = [z;sF.fhat;z];
    end
  end
  
  function out = get.antipodal(sF)
    if sF.bandwidth == 0
      out = true;
      return
    end
    sF = reshape(sF,numel(sF));
    dd = sum( abs(sF.fhat - flip(sF.fhat,1)).^2,1);
    nF = norm(sF)';
    out = all(sqrt(dd(nF>0)) ./ nF((nF>0)) <1e-4);
    % test whether fhat is symmetric fhat_n = conj(fhat_-n)
  end
  
  function sF = set.antipodal(sF,value)
    %if value, sF = sF.even; end
    if ~value, return; end
    s = size(sF);
    sF = reshape(sF,prod(s));
    sF.fhat = 0.5*(sF.fhat+flip(sF.fhat,1));
    sF = reshape(sF,s);
  end

  function out = get.isReal(sF)
    if sF.bandwidth == 0
      out = isalmostreal(sF.fhat,'precision',4);
      return
    end
    sF = reshape(sF,numel(sF));
    dd = sum( abs(sF.fhat - conj(flip(sF.fhat,1))).^2,1);
    nF = norm(sF)';
    out = all(sqrt(dd(nF>0)) ./ nF((nF>0)) <1e-4);
    % test whether fhat is symmetric fhat_n = conj(fhat_-n)
  end
  
  function sF = set.isReal(sF,value)
    if ~value, return; end
    s = size(sF);
    sF = reshape(sF,prod(s));
    sF.fhat = 0.5*(sF.fhat+conj(flip(sF.fhat,1)));
    sF = reshape(sF,s);
  end

  function d = size(sF, varargin)
    d = size(sF.fhat);
    d = d(2:end);
    if isscalar(d), d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end
  end

  function n = numel(sF)
    n = prod(size(sF)); %#ok<PSIZE>
  end

  function l = length(sF)
    l = prod(size(sF));  %#ok<PSIZE>
  end

end

methods (Static = true)
%   sF = approximation(v, y, varargin);
  sF = quadrature(f, varargin);
end

end
