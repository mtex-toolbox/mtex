function SO3F = smooth(SO3F,varargin)
% smooth SO3Fun
%
% Input
%  SO3F - @SO3Fun
%  psi  - @SO3Kernel (smoothing kernel)
%
% Options
%  halfwidth - halfwidth of the de la Vallee Poussin kernel to be used for smoothing
%
% Output
%  SO3F - smoothed @SO3Fun
%

% get smoothing kernel
if nargin >= 2 && isa(varargin{1},'SO3Kernel')
  psi = varargin{1};
else
  psi = SO3DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',5*degree));
end

SO3F = conv(SO3F,psi);

end