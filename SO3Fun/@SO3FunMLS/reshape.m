function SO3F = reshape(SO3F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  SO3F.values = reshape(SO3F.values, [length(SO3F.nodes) varargin{:}]);
else % varargin is cell array
  SO3F.values = reshape(SO3F.values, length(SO3F.nodes), varargin{:});
end


end
