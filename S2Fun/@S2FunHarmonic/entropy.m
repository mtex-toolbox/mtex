function E = entropy(sF, varargin)
% log of a function
%
% Syntax
%   E = entropy(sF)
%
% Input
%  sF - @S2FunHarmonic
%
% Output
%  E - entropy
%

% get some quadrature nodes
[nodes, W] = quadratureS2Grid(max(128,sF.bandwidth));

f = sF.eval(nodes);

E = -real(sum(W .* f .* log(f),1)) / 4 /pi;
E = reshape(E,size(sF));

end
