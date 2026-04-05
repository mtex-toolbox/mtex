function SO3F = transpose(SO3F)
% overloads transpose .'
%
% Syntax
%   SO3F.'
%

dim = length(size(SO3F));
SO3F = permute(SO3F, [2 1 3:dim]);

end