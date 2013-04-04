function odf = calcODF(ebsd,varargin)
% calculate ODF from EBSD data via kernel density estimation
%
% *calcODF* is one of the core functions of the MTEX toolbox.
% It estimates an ODF from given EBSD individual crystal orientations by 
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
%% Syntax
% calcODF(ebsd,...,param,var,...) - returns an @ODF calculated via kernel density estimation
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  odf - @ODF
%
%% Options
%  HALFWIDTH        - halfwidth of the kernel function 
%  RESOLUTION       - resolution of the grid where the ODF is approximated
%  KERNEL           - kernel function (default -- de la Valee Poussin kernel)
%  L/HARMONICDEGREE - (if Fourier) order up to which Fourier coefficients are calculated
%
%% Flags
%  SILENT           - no output
%  EXACT            - no approximation to a corser grid
%  FOURIER          - force Fourier method
%  BINGHAM          - model bingham odf
%  noFourier        - no Fourier method
%
%% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% extract orientations
ori = get(ebsd,'orientations');

% extract weights
if isfield(ebsd.options,'weight')
  varargin = [varargin,'weight',get(ebsd,'weight')];
end

% compute ODF
odf = calcODF(ori,varargin{:});
