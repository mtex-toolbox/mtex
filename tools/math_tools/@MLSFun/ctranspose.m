function F = ctranspose(F)
% overloads ctranspose
%
% Syntax
%   F'
%

F = conj(F.');

end
