function SO3F = permute(SO3F, varargin)
% overloads permute

SO3F.values = permute(SO3F.values, [1 varargin{:}+1]);

end