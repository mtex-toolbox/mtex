function q = directionalMagnitude(T,v)
% magnitude of a tensor in direction v
%
% Formula
%
%  q = T_i1i2i3...id v_i1 v_i2 v_i3 ... v_id
%
% Input
%  T - @tensor
%  v - direction (@vector3d / @Miller)
%
% Ouptut
%  q - magnitude of a tensor in direction v
%
% See Also

% return a function if required
if nargin == 1 || isempty(v)
  q = S2FunHarmonicSym.quadrature(@(x) directionalMagnitude(T,x),'bandwidth',4,T.CS);
  
  return
end

% compute tensor products with directions v with respect to all dimensions
while T.rank > 0
  T = EinsteinSum(T,[-1 1:T.rank-1],v.normalize,-1);
end

q = T.M;
if length(v)>1
  q = reshape(q,size(v));
end
