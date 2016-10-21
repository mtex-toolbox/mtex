function odf = calcKernelODF(ori,varargin)
% calculate ODF from individuel orientations via kernel density estimation
%
% *calcKernelODF* is one of the core function of the MTEX toolbox.
% It estimates an ODF from a set of individual crystal orientations by
% <EBSD2odf.html kernel density estimation>.
%
% The function *calcKernelODF* has several options to control the halfwidth
% of the kernel functions, the resolution, etc. Most important the
% estimated ODF is affected by the *halfwidth* of the kernel function.
%
% If the halfwidth is large the estimated ODF is smooth whereas a small
% halfwidth results in a sharp ODF. It depends on your prior information
% about the ODF to choose this parameter right. Look at this
% <EBSDSimulation_demo.html description> for an exhausive discussion.
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
% ebsd_demo EBSD2odf EBSDSimulation_demo loadEBSD ODF/calcEBSD EBSD/calcKernel kernel/kernel

% remove nan orientations
ori = subSet(ori,~isnan(ori));

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% extract weights
if check_option(varargin,'weights')
  weights = get_option(varargin,'weights');
else
  weights = ones(1,length(ori));
end
weights = weights ./ sum(weights(:));

% extract kernel function
psi = deLaValeePoussinKernel('halfwidth',10*degree,varargin{:});
psi = get_option(varargin,'kernel',psi);
hw = psi.halfwidth;

if (check_option(varargin,'exact') || length(ori) < 1000) && ~check_option(varargin,'test')
  
  % set up exact ODF
  odf = unimodalODF(ori,psi,ori.CS,ori.SS,'weights',weights);
  
else
  
  % define a indexed grid
  res = get_option(varargin,'resolution',max(0.75*degree,hw / 2));
  if ori.antipodal, aP = {'antipodal'}; else aP = {}; end
  S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res,aP{:});

  % construct a sparse matrix showing the relatation between both grids
  M = sparse(1:length(ori),find(S3G,ori),weights,length(ori),length(S3G));

  % compute weights
  weights = full(sum(M,1));
  weights = weights ./ sum(weights);

  % eliminate spare rotations in grid
  S3G = subGrid(S3G,weights~=0);
  weights = weights(weights~=0);
  
  % set up approximated ODF
  odf = unimodalODF(S3G,psi,ori.CS,ori.SS,'weights',weights);
end
  
end
