function S2F = smooth(S2F,varargin)
% smooth S2Fun
%
% Input
%  SO3F - @S2Fun
%  psi  - @S2Kernel (smoothing kernel)
%
% Options
%  halfwidth - halfwidth of the de la Vallee Poussin kernel to be used for smoothing
%
% Output
%  S2F - smoothed @S2Fun
%

% get smoothing kernel
if nargin >= 2 && isa(varargin{1},'S2Kernel')
  psi = varargin{1};
else
  psi = S2DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',5*degree));
end

S2F = conv(S2F,psi);

end