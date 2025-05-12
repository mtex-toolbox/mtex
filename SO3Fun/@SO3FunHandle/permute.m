function SO3F = permute(SO3F, varargin)
% overloads permute

SO3F.fun = @(rot) permute(SO3F.eval(rot), [1 varargin{:}+1]) ;

end