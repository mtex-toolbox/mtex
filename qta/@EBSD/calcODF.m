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
% <EBSDSimulation_demo.html description> for exhausive discussion.
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
g = getgrid(ebsd,'checkPhase',varargin{:});
gridlen = GridLength(g);
if gridlen == 0, odf = ODF; return, end

% extract weights
if check_option(varargin,'weight')
  weight = get_option(varargin,'weight');
elseif isfield(ebsd(1).options,'weight')
  % ignore nans
  %ebsd = delete(ebsd,isnan(get(ebsd,'weight')));
  weight = get(ebsd,'weight');  
else
  weight = ones(1,gridlen);
end
weight = weight ./ sum(weight(:));

% get halfwidth and kernel
[k hw] = extract_kernel(g,varargin);

vdisp([' used kernel: ' char(k)],varargin{:});

%% Fourier ODF

if (gridlen*length(ebsd(1).CS) > 200 && bandwidth(k) < 32) ...
    || check_option(varargin,'Fourier')
  vdisp(' construct Fourier odf',varargin{:});
  odf = ODF(g,weight,k,...
    ebsd(1).CS,ebsd(1).SS,'comment',['ODF estimated from ',getcomment(ebsd(1))]);
  odf = calcFourier(odf,max(10,bandwidth(k)));
  odf = FourierODF(odf);
  return
  
%% exact calculation
elseif check_option(varargin,'exact') || gridlen*length(ebsd(1).CS) < 2000
  vdisp(' construct exact odf',varargin{:});
  odf = ODF(g,weight,k,...
    ebsd(1).CS,ebsd(1).SS,'comment',['ODF estimated from ',getcomment(ebsd(1))]);  
  return
end


%% approximation on a corser grid

%% get resolution
res = get_option(varargin,'resolution',max(0.75*degree,hw / 2));

% %% first approximation
% 
% % generate approximation grid
% [maxalpha,maxbeta,maxgamma] = getFundamentalRegion(ebsd.CS,ebsd.SS);
% nalpha = round(2*maxalpha/res);
% nbeta = round(2*pi/res);
% ngamma = round(4*pi/res);
% 
% % approximate
% [alpha,beta,gamma] = quat2euler(quaternion(ebsd.orientations));
% ialpha = 1+round(nalpha * mod(alpha,maxalpha) ./ maxalpha);
% ibeta = 1+round(nbeta * beta ./ maxbeta);
% igamma = 1+round(ngamma * gamma ./ maxgamma);
% 
% ind = ialpha + nalpha * (ibeta + nbeta * igamma);
% c = histc(ind,1:nalpha*nbeta*ngamma);


%% generate grid
S3G = extract_SO3grid(ebsd,varargin{:},'resolution',res);

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
  for i = 1:length(ind) % TODO -> make it faster
    d(ind(i)) = d(ind(i)) + weight(sind(i));
  end

end
d = d ./ sum(d(:));

%% eliminate spare rotations in grid
del = d ~= 0;
S3G = subGrid(S3G,del);
d = d(del);

%% generate ODF

odf = ODF(S3G,d,k,ebsd(1).CS,ebsd(1).SS,...
  'comment',['ODF estimated from ',getcomment(ebsd(1))]);

%% check wether kernel is to wide
if check_option(varargin,'small_kernel') && hw > 2*getResolution(S3G)
  
  hw = 2/3*getResolution(S3G);
  k = kernel('de la Vallee Poussin','halfwidth',hw);
  vdisp([' recalculate ODF for kernel: ',char(k)],varargin{:});
  d = eval(odf,S3G); %#ok<EVLC>
  odf = ODF(S3G,d./sum(d),k,ebsd(1).CS,ebsd(1).SS,...
    'comment',['ODF estimated from ',getcomment(ebsd(1))]);
end
end
%%

function vdisp(s,varargin)
if ~check_option(varargin,'silent'), disp(s);end
end
