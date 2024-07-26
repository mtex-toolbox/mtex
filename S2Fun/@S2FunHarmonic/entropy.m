function E = entropy(sF, varargin)
% entropy of a function
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
% Description
%
% $$ int f(x) \cdot \log f(x) d x$$
%

% get some quadrature nodes
S2G = quadratureS2Grid(max(128,sF.bandwidth));

f = sF.eval(S2G(:));

% compute the entropy
E = -real(sum(S2G.weights(:) .* f .* log(f),1)) / 4 /pi;
E = reshape(E,size(sF));

end
