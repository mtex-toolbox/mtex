function sF = reshape(sF, varargin)
% overloads reshape

if isempty(varargin{:})
  sF.fhat = reshape(sF.fhat, (sF.bandwidth+1)^2, varargin{:});
else
  sF.fhat = reshape(sF.fhat, [(sF.bandwidth+1)^2 varargin{:}]);
end

end
