function SO3F = permute(SO3F, varargin)
% overloads permute

SO3F.weights = permute(SO3F.weights, [1 varargin{:}+1]);
SO3F.c0 = permute(SO3F.c0, varargin{:});

end