function odf = calcODF(varargin)
% computes an ODF from individual orientations
%
% The function *calcODF* applies one of the following algorithms to compute
% an ODF from a list of orientations.
%
% # direct kernel density estimation 
% # kernel density estimation via Fourier series
% # Bingham estimation
%
% Syntax
%
%   % use kernel density estimation with a 10 degree kernel
%   odf = calcODF(ori,'halfwidth',10*degree) 
%
%   % use grain area as weights for the orientations
%   odf = calcODF(grains.meanOrientation,'weights',grains.area)
%
%   % use a specific kernel
%   psi = SO3AbelPoissonKernel('halfwidth',10*degree)
%   odf = calcODF(ori,'kernel',psi) 
%
%   % compute the ODF as a Fourier series of order 16
%   odf = calcODF(ori,'order',16) 
%
% Input
%  ori  - @orientation
%
% Output
%  odf - @SO3Fun
%
% Options
%  weights    - list of weights for the orientations
%  halfwidth  - halfwidth of the kernel function
%  resolution - resolution of the grid where the ODF is approximated
%  kernel     - SO3Kernel function (default -- SO3 de la Valee Poussin kernel)
%  order      - order up to which Fourier coefficients are calculated
%
% Flags
%  silent     - no output
%  exact      - no approximation to a coarser grid
%  Fourier    - force Fourier method
%  Bingham    - model Bingham odf
%  noFourier  - no Fourier method
%
% See also
% orientation/calcFourierODF orientation/calcKernelODF orientation/calcBinghamODF ebsd_demo EBSD2odf EBSDSimulation_demo 

if isa(varargin{1},'orientation')
  
  warning('The command calcODF is depreciated! Please use calcDensity instead.')

  odf = calcDensity(varargin{1},varargin{:});
  
elseif isa(varargin{1},'EBSD')

  warning('Using calcODF with EBSD data is obsolete since MTEX 4.0. Use calcDensity(ebsd(''indexed'').orientations) instead.')
  ebsd = varargin{1};
  odf = calcDensity(ebsd('indexed').orientations,varargin{:});
  
end

end

