function odf = calcODF(ebsd,varargin)
% calculate ODF from EBSD data via kernel density estimation
%
% *calcODF* is one of the main function of the MTEX toolbox.
% It estimates an ODF from given EBSD individual crystal orientations by 
% <EBSD2odf_estimation.html kernel density estimation>. 
% The function *calcODF* has several options to control the halfwidth of
% the kernel functions, the resolution, etc. Most important the estimated
% ODF is affected by the *halfwidth* of the kernel function. If the
% halfwidth is large the estimated ODF is smooth whereas a small halfwidth
% results in a sharp ODF. It depends on your prior information about the
% ODF to choose this parameter right. Look at this
% <EBSD_simulation_demo.html description> for exhausive discussion.
%
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  odf - @ODF
%
%% Options
%  HALFWIDTH  - halfwidth of the kernel function 
%  RESOLUTION - resolution of the grid where the ODF is approximated
%  EXACT      - no approximation to a corser grid
%  KERNEL     - kernel function (default - de la Valee Poussin kernel)
%  SILENT     - no output
%
%% See also
% ebsd_demo EBSD2odf_estimation EBSDSimulation EBSD/loadEBSD ODF/simulateEBSD


vdisp('------ MTEX -- EBSD to ODF computation ------------------',varargin{:})
vdisp('performing kernel density estimation',varargin{:})

% extract orientations
g = getgrid(ebsd);

% get halfwidth
hw = get_option(varargin,'halfwidth',...
  max(getResolution(g) * 3,2*degree));
k = get_option(varargin,'kernel',...
      kernel('de la Vallee Poussin','halfwidth',hw),'kernel');

vdisp([' used kernel: ' char(k)],varargin{:});

%% exact calculation
if check_option(varargin,'exact') || GridLength(g)<200  
  d = ones(1,GridLength(g)) ./ GridLength(g);  
  odf = ODF(g,d,k,...
    ebsd(1).CS,ebsd(1).SS,'comment',['ODF estimated from ',getcomment(ebsd(1))]);  
  return
end

%% approximation on a corser grid

%% get resolution
res = get_option(varargin,'resolution',max(1.5*degree,hw / 2));

%% generate grid
S3G = SO3Grid(res,ebsd(1).CS,ebsd(1).SS);
vdisp([' approximation grid: ' char(S3G)],varargin{:});

%% restrict single orientations to this grid

% init variables
g = quaternion(g);
d = zeros(1,GridLength(S3G));

% iterate due to memory restrictions?
maxiter = ceil(length(ebsd(1).CS)*length(ebsd(1).SS)*numel(g) /...
  get_mtex_option('memory',300 * 1024));
if maxiter > 1, progress(0,maxiter);end

for iter = 1:maxiter
   
  if maxiter > 1, progress(iter,maxiter); end
   
  dind = ceil(numel(g) / maxiter);
  sind = 1+(iter-1)*dind:min(numel(g),iter*dind);
      
  ind = find(S3G,g(sind));
  for i = 1:length(ind)
    d(ind(i)) = d(ind(i)) + 1;
  end

end
d = d ./ numel(g);

%% eliminate spare rotations in grid
S3G = subGrid(S3G,d ~= 0);
d = d(d~=0);

%% generate ODF

odf = ODF(S3G,d,k,ebsd(1).CS,ebsd(1).SS,...
  'comment',['ODF estimated from ',getcomment(ebsd(1))]);

%% check wether kernel is to wide
if check_option(varargin,'small_kernel') && hw > 2*getResolution(S3G)
  
  hw = 2/3*getResolution(S3G);
  k = kernel('de la Vallee Poussin','halfwidth',hw);
  vdisp([' recalculate ODF for kernel: ',char(k)],varargin{:});
  d = eval(odf,S3G);
  odf = ODF(S3G,d./sum(d),k,ebsd(1).CS,ebsd(1).SS,...
    'comment',['ODF estimated from ',getcomment(ebsd(1))]);
end
end
%%

function vdisp(s,varargin)
if ~check_option(varargin,'silent'), disp(s);end
end
