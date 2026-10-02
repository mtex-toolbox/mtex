function psi = calcKernel(ebsd,varargin)
% compute an optimal kernel function for ODF estimation from EBSD data
%
% Neighbouring pixels of one grain are not independent observations of the
% texture. The halfwidth is therefore selected from the energies of parts of
% the map that share no grain, which needs the grainId of every pixel.
%
% Syntax
%   [grains,ebsd.grainId] = calcGrains(ebsd);
%   psi = calcKernel(ebsd('Forsterite'))
%   psi = calcKernel(ebsd('Forsterite'),'method','conservative')
%
% Input
%  ebsd - @EBSD of one phase with grainId
%
% Output
%  psi - @SO3DeLaValleePoussinKernel
%
% Options
%  method - |'UCV'| (default) or |'conservative'|, see <selectHalfwidth.html selectHalfwidth>
%
% See also
% selectHalfwidth orientation/calcKernel rotation/calcDensity

method = get_option(varargin,'method','UCV');
assert(any(strcmpi(method,{'UCV','conservative'})),'MTEX:calcKernel',...
  ['''%s'' counts every pixel as an independent observation. Use ''UCV'' or ' ...
  '''conservative'', or select the kernel from the grain mean orientations.'],method);

hw = selectHalfwidth(ebsd.orientations,method,'groups',ebsd.grainId,varargin{:});
psi = SO3DeLaValleePoussinKernel('halfwidth',hw);
