function odf = calcKernelODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcKernelODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% <EBSD2ODF.html kernel density estimation>.
%
% The function *calcKernelODF* has several options to control the halfwidth
% of the kernel functions, the resolution, etc. Most important the
% estimated ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small
% halfwidth results in a sharp ODF. It depends on your prior information
% about the ODF to choose this parameter right. Look at this
% <EBSD2ODF.html description> for an exhausive discussion.
%
% Syntax
%   odf = calcKernelODF(ori)
%   odf = calcKernelODF(grains.meanOrientation,'weigths',grains.area)
%   odf = calcKernelODF(ebsd.orientations,'halfwidth',5*degree)
%
% Input
%  ori - @orientation
%
% Output
%  odf - @ODF
%
% Options
%  halfwidth  - halfwidth of the kernel function
%  resolution - resolution of the grid where the ODF is approximated
%  kernel     - kernel function (default -- de la Valee Poussin kernel)
%  weights    - list of weights for the orientations
%
% Flags
%  exact      - no approximation to a corser grid
%
% See also
% ebsd_demo EBSD2odf EBSDSimulation_demo EBSD/load ODF/calcEBSD EBSD/calcKernel kernel/kernel



% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% extract weights
if check_option(varargin,'weights')
  weights = get_option(varargin,'weights');
else
  weights = ones(1,length(ori));
end

% remove nan orientations and weights
weights = weights(~isnan(ori));
ori = subSet(ori,~isnan(ori));

% normalize weights
weights = weights ./ sum(weights(:));

% extract kernel function
psi = deLaValleePoussinKernel('halfwidth',10*degree,varargin{:});
psi = get_option(varargin,'kernel',psi);
hw = psi.halfwidth;

% if we have to many orientation approximate them on a grid
if length(ori) > 1000 && ~check_option(varargin,'exact')
    
  [ori,weights] = gridify(ori,'weights',weights,...
    'resolution',max(0.75*degree,hw / 2), varargin{:});
  
end

% set up exact ODF
odf = unimodalODF(ori,psi,ori.CS,ori.SS,'weights',weights);
  
end
