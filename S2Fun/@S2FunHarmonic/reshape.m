function sF = reshape(sF, varargin)
% overloads reshape

sF.fhat = reshape(sF.fhat, (sF.bandwidth+1)^2, varargin{:});

end
