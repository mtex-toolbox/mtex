function r = reflection(n)
% defines a reflection at plane with normal n
%
% Syntax
%   r = reflection(n)
%
% Input
%  n - plane normals of the reflection planes
%
% Output
%  r - improper @rotation
%

r = -rotation.byAxisAngle(n,pi);
