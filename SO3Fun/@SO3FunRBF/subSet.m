function SO3F = subSet(SO3F,varargin)
% subindex SO3FunRBF

SO3F.c0 = SO3F.c0(varargin{:});
SO3F.weights = SO3F.weights(:, varargin{:});

end
