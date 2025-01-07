function sF = smooth(sF,varargin)
% smooth S1Fun
%
% Input
%  sF - @S1Fun
%  psi  - @S1Kernel (smoothing kernel)
%
% Options
%  halfwidth - halfwidth of the de la Vallee Poussin kernel to be used for smoothing
%
% Output
%  sF - smoothed @S1Fun
%

% get smoothing kernel
if nargin >= 2 && isa(varargin{1},'S1Kernel')
  psi = varargin{1};
else
  psi = S1DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',2.9*degree));
end

sF = conv(sF,psi);

end