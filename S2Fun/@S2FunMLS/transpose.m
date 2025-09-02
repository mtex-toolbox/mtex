function S2F = transpose(S2F)
% overloads transpose .'
%
% Syntax
%   S2F.'
%

dim = length(size(S2F));
S2F.values = permute(S2F.values, [1 3 2 4:dim+1]);

end