function SO3F = transpose(SO3F)
% overloads transpose .'
%
% Syntax
%   SO3F.'
%

dim = length(size(SO3F));
SO3F.fhat = permute(SO3F.fhat, [1 3 2 4:dim+1]);

end