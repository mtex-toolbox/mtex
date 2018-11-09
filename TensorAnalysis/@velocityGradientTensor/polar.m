function [R,U,V] = polar(L,t)
% polar decomposition of velocity gradient tensor
%
% Syntax
%   [R,U,V] = polar(L)
%   [R,U,V] = polar(L,t)
%
% Input
%  L - @velocityGradientTensor
%  t - time
%
% Output
%  R - rigid boddy rotation
%  U - right stretch tensor
%  V - left stretch tensor

if nargin == 1, t = 1; end

[R,U,V] = polar@tensor(t.*L);

end

