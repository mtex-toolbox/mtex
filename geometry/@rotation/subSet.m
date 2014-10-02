function r = subSet(r,ind)
% indexing of rotation
%
% Syntax
%   subSet(q,ind) % 
%

r = subSet@quaternion(r,ind);
r.i = r.i(ind);

