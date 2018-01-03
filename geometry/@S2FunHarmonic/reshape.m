function sF = reshape(sF, varargin)

sF.fhat = reshape(sF.fhat, (sF.bandwidth+1)^2, varargin{:});

end
