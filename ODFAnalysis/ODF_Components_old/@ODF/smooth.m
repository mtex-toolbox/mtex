function odf = smooth(odf,varargin)
% smooth ODF
%
% Input
%  odf - @ODF
%  res - resolution
%
% Output
%  odf - smoothed @ODF
%

% get smoothing kernel
if nargin >= 2 && isa(varargin{1},'kernel')
  psi = varargin{1};
else
  psi = deLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',5*degree));
end

% smooth components
for i = 1:length(odf.components)
  odf.components{i} = odf.components{i}.smooth(psi);
end
