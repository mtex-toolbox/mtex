function m = symeq(m1,m2)
% directions symmetrically equivalent to m1
%% Syntax
%  m = symeq(m1)    - Miller indice symmetrically equivalent to m1
%  e = symeq(m1,m2) - check if vectors symmetrically equivalent
%
%% Input
%  m1, m2 - @Miller
%
%% Output
%  m - @Miller
%  e - logical

if nargin == 1
  m = vec2Miller(symvec(m1),m1.CS);  
else
  m = isnull(angle(m1,m2));
end
