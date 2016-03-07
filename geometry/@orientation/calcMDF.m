function mdf = calcMDF(mori,varargin)
% computes an MDF from individuel orientations or misorientations
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
%   mori = grains.boundary.misorientation
%   mdf = calcMDF(mori,'halfwidth',10*degree) 
%
%   % compute an uncorrelated MDF
%   mdf = calcMDF(grains('phase1').meanorientation)
%
%   % use grain area as weights for the orientations
%   mdf = calcMDF(grains('phase1').meanOrientation,'weights',grains('phase1').diameter)
%
%   % use a specific kernel
%   psi = AbelPoissonKernel('halfwidth',10*degree)
%   mdf = calcMDF(mori,'kernel',psi) 
%
%   % compute the MDF as a Fourier series of order 16
%   mdf = calcMDF(mori,'order',16) 
%
% Input
%  ori  - @orientation
%  mori - misorientation
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

% if orientations have been specified
if isa(mori.SS,'specimenSymmetry')
  
  % compute an ODF first
  odf1 = calcFourierODF(mori,varargin{:});
  
  if nargin > 1 && isa(varargin{1},'orientation')
    
    % maybe a second ODF is needed
    odf2 = calcFourierODF(varargin{1},varargin{:});
    
    % compute the MDF
    mdf = calcMDF(odf1,odf2);
    
  else
    
    % compute the MDF
    mdf = calcMDF(odf1);
    
  end
  
  return
end

if check_option(varargin,'antipoal') && mori.CS == mori.SS
  mori = [mori(:);inv(mori(:))]; 
end

mdf = calcODF(mori,'halfwidth',7.5*degree,varargin{:});