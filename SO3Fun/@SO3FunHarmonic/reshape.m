function SO3F = reshape(SO3F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  SO3F.fhat = reshape(SO3F.fhat, [deg2dim(SO3F.bandwidth+1) varargin{:}]);
else % varargin is cell array
  SO3F.fhat = reshape(SO3F.fhat, deg2dim(SO3F.bandwidth+1), varargin{:});
end


end
