function m = SchmidTensor(sS)
% Schmid tensors for a list of slip systems
%
% Syntax
%   m = SchmidTensor(sS)
%
%   sigma = stressTensor.uniaxial(xvector)
%   crss = m:sigma
%
% Input
%  sS - list of @slipSystem
%
% Output
%  m - Schmid tensor @velocityGradientTensor
%

% actually we need to multiply with the slipping rates $\dot gamma(t)$ to
% obtain the velocity gradient tensors
m = SchmidTensor(sS.n,sS.b);