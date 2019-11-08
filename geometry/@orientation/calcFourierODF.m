function odf = calcFourierODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% <EBSD2ODF.html kernel density estimation>.
%
% The function *calcODF* has several options to control the halfwidth of
% the kernel functions, the resolution, etc. Most important the estimated
% ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small
% halfwidth results in a sharp ODF. It depends on your prior information
% about the ODF to choose this parameter right. Look at this
% <EBSD2ODF.html  description> for exhausive discussion.
%
% Syntax
%   calcODF(ori)
%   calcODF(ori,'kernel',psi)
%   calcODF(ori,'bandwidth',32)
%
% Input
%  ori  - @orientation
%
% Output
%  odf - @ODF
%  psi - @kernel
%
% Options
%  halfwidth - halfwidth of the kernel function
%  kernel    - kernel function (default -- de la Valee Poussin kernel)
%  bandwidth - order up to which Fourier coefficients are calculated
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo EBSD/load ODF/calcEBSD EBSD/calcKernel kernel/kernel

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% construct an exact kernel ODF
odf = calcKernelODF(ori,varargin{:},'exact');

% get bandwidth
L = get_option(varargin,{'L','HarmonicDegree'},...
  min(max(1,odf.components{1}.psi.bandwidth),96),'double');

% check kernel has at most the requested bandwidth
if odf.components{1}.psi.bandwidth > L
  warning('MTEX:EBSD:calcODF',['The estimated ODF will suffer from ' ...
    'truncation errors when truncated to harmonic degree ' int2str(L) ...
    '. You  might want to increase the harmonic degree or the halfwidth.'])
end

odf = FourierODF(odf,get_option(varargin,{'L','bandwidth','fourier'},L,'double'));
odf.antipodal = odf.antipodal || ori.antipodal;
