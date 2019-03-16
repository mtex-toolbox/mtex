function varargout = polar(L,t)
% polar decomposition of velocity gradient tensor
%
% Syntax
%   [R,V,U] = polar(L)
%   [R,V,U] = polar(L,t)
%
% Input
%  L - @velocityGradientTensor
%  t - time
%
% Output
%  R - rigid boddy rotation
%  V - left stretch tensor
%  U - right stretch tensor
%

if nargin == 1, t = 1; end

[varargout{1:nargout}] = polar@tensor(t.*L);

end
