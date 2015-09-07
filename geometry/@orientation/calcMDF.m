function mdf = calcMDF(ori,varargin)
% computes an MDF from individuel orientations
%
% The function *calcMDF* applies one of the following algorithms to compute
% an MDF from a list of orientations.
%
% # direct kernel density estimation 
% # kernel density estimation via Fourier series
% # Bingham estimation
%
% Syntax
%
%   % use kernel density estimation with a 10 degree kernel
%   mdf = calcMDF(ori,'halfwidth',10*degree) 
%
%   % use grain area as weights for the orientations
%   mdf = calcMDF(grains.meanOrientation,'weights',grains.area)
%
%   % use a specific kernel
%   psi = AbelPoissonKernel('halfwidth',10*degree)
%   mdf = calcMDF(ori,'kernel',psi) 
%
%   % compute the MDF as a Fourier series of order 16
%   mdf = calcMDF(ori,'order',16) 
%
% Input
%  ori  - @orientation
%
% Output
%  mdf - @ODF
%
% Options
%  weights    - list of weights for the orientations
%  halfwidth  - halfwidth of the kernel function
%  resolution - resolution of the grid where the MDF is approximated
%  kernel     - kernel function (default -- de la Valee Poussin kernel)
%  order      - order up to which Fourier coefficients are calculated
%
% Flags
%  silent           - no output
%  exact            - no approximation to a corser grid
%  Fourier          - force Fourier method
%  Bingham          - model bingham mdf
%  noFourier        - no Fourier method
%
% See also
% orientation/calcFourierMDF orientation/calcKernelMDF orientation/calcBinghamMDF ebsd_demo EBSD2mdf EBSDSimulation_demo 

if check_option(varargin,'antipoal')
  ori = [ori(:);inv(ori(:))]; 
end

mdf = calcODF(ori,'halfwidth',7.5*degree,varargin{:});