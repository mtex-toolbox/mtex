function SO3F = permute(SO3F, varargin)
% overloads permute

SO3F.fhat = permute(SO3F.fhat, [1 varargin{:}+1]);

end