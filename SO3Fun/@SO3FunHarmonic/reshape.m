function F = reshape(F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  F.fhat = reshape(F.fhat, [deg2dim(F.bandwidth+1) varargin{:}]);
else % varargin is cell array
  F.fhat = reshape(F.fhat, deg2dim(F.bandwidth+1), varargin{:});
end


end
