function SO3F = transpose(SO3F)
% overloads transpose .'
%
% Syntax
%   SO3F.'
%

dim = length(size(SO3F));
SO3F.c0 = permute(SO3F.c0, [2 1 3:dim]);
SO3F.weights = permute(SO3F.weights, [1 3 2 4:dim+1]);

end