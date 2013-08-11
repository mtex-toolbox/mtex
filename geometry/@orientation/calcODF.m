function odf = calcODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% [[EBSD2odf.html kernel,density estimation]].
%
% The function *calcODF* has several options to control the halfwidth of
% the kernel functions, the resolution, etc. Most important the estimated
% ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small halfwidth
% results in a sharp ODF. It depends on your prior information about the
% ODF to choose this parameter right. Look at this
% [[EBSDSimulation_demo.html, description]] for exhausive discussion.
%
% Syntax
%   calcODF(ori,...,param,var,...)
%   calcODF(ebsd,...,param,var,...)
%
% Input
%  ori  - @orientation
%  ebsd - @EBSD
%
% Output
%  odf - @ODF
%
% Options
%  HALFWIDTH        - halfwidth of the kernel function
%  RESOLUTION       - resolution of the grid where the ODF is approximated
%  KERNEL           - kernel function (default -- de la Valee Poussin kernel)
%  L/HARMONICDEGREE - (if Fourier) order up to which Fourier coefficients are calculated
%
% Flags
%  SILENT           - no output
%  EXACT            - no approximation to a corser grid
%  FOURIER          - force Fourier method
%  BINGHAM          - model bingham odf
%  noFourier        - no Fourier method
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% Bingham ODF estimation
if check_option(varargin,'bingham')  
  odf = calcBinghamODF(ori,varargin{:});
  return;
end
  
% estimate kernel function
psi = getKernel(ori,varargin{:});

if  ~check_option(varargin,{'exact','noFourier'}) && ...
    (check_option(varargin,'Fourier') || ...
    strcmpi(get(psi,'name'),'dirichlet') || ...
    (length(ori) > 200 && bandwidth(psi) < 33))
  
  odf = calcFourierODF(ori,varargin{:},'kernel',psi);
  
else
    
  odf = calcKernelODF(ori,varargin{:},'kernel',psi);
  
end

