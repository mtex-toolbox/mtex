function SO3F = reshape(SO3F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  SO3F.c0 = reshape(SO3F.c0, [numel(SO3F.center) varargin{:}]);
  SO3F.weights = reshape(SO3F.weights, [numel(SO3F.center) varargin{:}]);
else % varargin is cell array
  SO3F.c0 = reshape(SO3F.c0, varargin{:});
  SO3F.weights = reshape(SO3F.weights, length(SO3F.center), varargin{:});
end


end
