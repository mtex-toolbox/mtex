function sF = reshape(sF, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  sF.fhat = reshape(sF.fhat, [(sF.bandwidth+1)^2 varargin{:}]);
else % varargin is cell array
  sF.fhat = reshape(sF.fhat, (sF.bandwidth+1)^2, varargin{:});
end


end
