function v = plus(v1,v2)
% ensure that the result is not a fibonacciS2Grid anymore
%
% A fibonacciS2Grid is defined by its spiral construction and is used as a
% guarantee for pairwise distinct nodes, see S2FunMLS. Shifting the grid
% destroys both, hence demote the operands before adding.

if isa(v1,'fibonacciS2Grid'), v1 = vector3d(v1); end
if isa(v2,'fibonacciS2Grid'), v2 = vector3d(v2); end

v = v1 + v2;
