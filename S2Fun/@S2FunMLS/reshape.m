function S2F = reshape(S2F, varargin)
% overloads reshape

if length(varargin{1}) > 1 % varargin is matrix
  S2F.values = reshape(S2F.values, [length(S2F.nodes) varargin{:}]);
else % varargin is cell array
  S2F.values = reshape(S2F.values, length(S2F.nodes), varargin{:});
end


end
