function m = SchmidTensor(n,b)
% computes the Schmidt tensor
%
% Input
%  n - normal vector of the slip or twinning plane
%  b - Burgers vector (slip) or twin shear direction (twinning)
%
% Output
%  m - Schmid tensor @velocityGradientTensor
%

%
% actually we need to multiply with the slipping rates $\dot gamma(t)$ to
% obtain the velocity gradient tensors
m = velocityGradientTensor(dyad(b.normalize,n.normalize));

end

