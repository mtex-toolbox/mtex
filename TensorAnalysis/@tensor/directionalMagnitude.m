function T = directionalMagnitude(T,v)
% magnitude of a tensor in direction v
%
% Description
% The tensor is contracted with the direction in every index,
%
% $$ q = T_{i_1 i_2 \ldots i_d} v_{i_1} v_{i_2} \cdots v_{i_d}. $$
%
% Syntax
%
%   q = directionalMagnitude(T,v) % magnitude in the directions v
%   S2F = directionalMagnitude(T) % magnitude as a function on the sphere
%
% Input
%  T - @tensor
%  v - direction (@vector3d / @Miller)
%
% Output
%  q   - magnitude of a tensor in direction v
%  S2F - @S2FunHarmonicSym
%

% return a function if required
if nargin == 1 || isempty(v)
  fr = T.framePrivate;
  T = S2FunHarmonicSym.quadrature(@(x) directionalMagnitude(T,x),'bandwidth',4,T.CS);
  % an own frame of the tensor rides along - only frames carry conventions
  T.framePrivate = fr;

  return
end

% compute tensor products with directions v with respect to all dimensions
while ~isnumeric(T)
  T = EinsteinSum(T,[-1 1:T.rank-1],v.normalize,-1,'keepClass');
end

if length(v)>1, T = reshape(T,size(v)); end
