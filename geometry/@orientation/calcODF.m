function odf = calcODF(ori,varargin)
% computes an ODF from individuel orientations
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
%   psi = AbelPoissonKernel('halfwidth',10*degree)
%   odf = calcODF(ori,'kernel',psi) 
%
%   % compute the ODF as a Fourier series of order 16
%   odf = calcODF(ori,'order',16) 
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
%  silent           - no output
%  exact            - no approximation to a corser grid
%  Fourier          - force Fourier method
%  Bingham          - model bingham odf
%  noFourier        - no Fourier method
%
% See also
% orientation/calcFourierODF orientation/calcKernelODF orientation/calcBinghamODF ebsd_demo EBSD2odf EBSDSimulation_demo 

% Bingham ODF estimation
if check_option(varargin,'bingham')  
  odf = calcBinghamODF(ori,varargin{:});
  return;
end
  
% estimate kernel function
psi = getKernel(ori,varargin{:});

if isa(ori.SS,'crystalSymmetry') || (~check_option(varargin,{'exact','noFourier'}) && ...
    (check_option(varargin,'Fourier') || ...
    isa(psi,'DirichletKernel') || ...
    (length(ori) > 200 && bandwidth(psi) < 33)))
  
  odf = calcFourierODF(ori,varargin{:},'kernel',psi);
  
else
    
  odf = calcKernelODF(ori,varargin{:},'kernel',psi);
  
end
