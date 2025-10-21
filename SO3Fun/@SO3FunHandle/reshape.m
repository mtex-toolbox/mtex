function SO3F = reshape(SO3F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  SO3F.fun = @(rot) reshape(SO3F.eval(rot), [length(rot) varargin{:}]);
else % varargin is cell array
  SO3F.fun = @(rot) reshape(SO3F.eval(rot), length(rot), varargin{:});
end


end
