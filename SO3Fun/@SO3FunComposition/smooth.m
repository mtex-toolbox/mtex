function odf = smooth(odf,varargin)
% smooth ODF
%
% Input
%  odf - @SO3Fun
%  res - resolution
%
% Output
%  odf - smoothed @SO3Fun
%

% get smoothing kernel
if nargin >= 2 && isa(varargin{1},'SO3Kernel')
  psi = varargin{1};
else
  psi = SO3deLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',5*degree));
end

% smooth components
for i = 1:length(odf.components)
  odf.components{i} = odf.components{i}.smooth(psi);
end
