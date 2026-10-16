function F = transpose(F)
% overloads transpose .'
%
% Syntax
%   F.'
%

F.values = permute(F.values,[1 3 2 4:length(size(F))+1]);

end
