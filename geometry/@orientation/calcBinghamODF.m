function odf = calcBinghamODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% [[EBSD2odf.html kernel,density estimation]].
%
% Input
%  ori  - @orientation
%
% Output
%  odf - @ODF
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% estimate Bingham parameters
[~,~,ev,kappa] = mean(ori,varargin{:});

% set up Bingham ODF
odf = BinghamODF(kappa,ev,ori.CS,ori.SS);
