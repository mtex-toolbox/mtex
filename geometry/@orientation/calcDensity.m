function odf = calcDensity(ori,varargin)
% computes an ODF from individuel orientations
%
% The function *calcDensity* applies one of the following algorithms to compute
% an ODF from a list of orientations.
%
% # direct kernel density estimation 
% # kernel density estimation via Fourier series
% # Bingham estimation
%
% Syntax
%
%   % use kernel density estimation with a 10 degree kernel
%   odf = calcDensity(ori,'halfwidth',10*degree) 
%
%   % use grain area as weights for the orientations
%   odf = calcDensity(grains.meanOrientation,'weights',grains.area)
%
%   % use a specific kernel
%   psi = AbelPoissonKernel('halfwidth',10*degree)
%   odf = calcDensity(ori,'kernel',psi) 
%
%   % compute the ODF as a Fourier series of order 16
%   odf = calcDensity(ori,'order',16) 
%
% Input
%  ori  - @orientation
%
% Output
%  odf - @ODF
%
% Options
%  weights    - list of weights for the orientations
%  halfwidth  - halfwidth of the kernel function
%  resolution - resolution of the grid where the ODF is approximated
%  kernel     - kernel function (default -- de la Valee Poussin kernel)
%  order      - order up to which Fourier coefficients are calculated
%
% Flags
%  silent     - no output
%  exact      - no approximation to a corser grid
%  Fourier    - force Fourier method
%  Bingham    - model bingham odf
%  noFourier  - no Fourier method
%
% See also
% orientation/calcFourierODF orientation/calcKernelODF orientation/calcBinghamODF ebsd_demo EBSD2odf EBSDSimulation_demo 

% TODO this could be done better!!!
% add grain exchange symmetry
if check_option(varargin,'antipoal') && ori.CS == ori.SS
  ori = [ori(:);inv(ori(:))]; 
end


% Bingham ODF estimation
if check_option(varargin,'bingham')  
  odf = calcBinghamODF(ori,varargin{:});
  return;
end
  
% extract kernel function
psi = deLaValleePoussinKernel('halfwidth',10*degree,varargin{:});
psi = get_option(varargin,'kernel',psi);

if  ~check_option(varargin,{'exact','noFourier'}) && ...
    (isa(ori.SS,'crystalSymmetry') || check_option(varargin,{'Fourier','harmonic'}) || ...
    isa(psi,'DirichletKernel') || ...
    (length(ori) > 200 && psi.bandwidth <= 96))
  
  odf = calcFourierODF(ori,varargin{:},'kernel',psi);
  
else
    
  odf = calcKernelODF(ori,varargin{:},'kernel',psi);
  
end
