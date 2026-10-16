function F = reshape(F,varargin)
% overloads reshape

if length(varargin{1}) > 1 % a size vector
  F.values = reshape(F.values,[numel(F.nodes) varargin{:}]);
else % the sizes as separate arguments
  F.values = reshape(F.values,numel(F.nodes),varargin{:});
end

end
