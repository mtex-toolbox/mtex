function [odf,alpha] = calcODF(pf,varargin)
% PDF to ODF inversion
%
% *calcODF* is one of the main function of the MTEX toolbox.
% It estimates an ODF from given Polefigure intensities by
% <PoleFigure2odf.html fitting an ODF that consists of a large number of unimodal ODFs to the data>.
% It does so by minimizing a least squares functional. The command
% *calcODF* supports <ghost_demo.html automatic ghost correction> and
% <dubna_demo.html the zero range method>.
% The function *calcODF* has several options to control convergence,
% resolution, smoothing, etc. See below for a complete description.
%
%
% Input
%  pf - @PoleFigure
%
% Options
%  KERNEL            - the ansatz functions (default = de la Vallee Poussin)
%  KERNELWIDTH | HALFWIDTH - halfwidth of the ansatz functions (default = 2/3 * resolution)
%  RESOLUTION        - localization grid for the ansatz fucntions (default = 3/2 resolution(pf))
%  BANDWIDTH         - bandwidth of the ansatz functions (default = max)
%  ITER_MAX          - maximum number of iterations (default = 11)
%  ITER_MIN          - minimum number of iterations (default = 5)
%  REGULARIZATION    - weighting coefficient lambda (default = 0)
%  ODF_SAVE          - save ODF simultanously
%  C0                - initial guess (default = [1 1 1 1 ... 1])
%
% Flags
%  ZERO_RANGE        - apply zero range method (default = )
%  NOGHOSTCORRECTION - omit ghost correction
%  ENSURE_DESCENT - stop iteration whenever no procress if observed
%  FORCE_ITER_MAX - allway go until ITER_MAX
%  RP_VALUES      - calculate RP values during iteration
%  ODF_TEST       - for testing only
%  SILENT         - no output
%
% Output
%  odf    - reconstructed @ODF
%  alpha  - scaling factors, calculated during reconstruction
%
% See also
% PoleFigure2odf ODF_demo PoleFigureSimulation_demo
% loadPoleFigure ImportPoleFigureData examples_index

tic

vdisp('------ MTEX -- PDF to ODF inversion ------------------',varargin{:})

% ------------------- get input--------------------------------------------

% take the mean over duplicated pole figure values
pf = unique(pf);

CS = pf.CS;
SS = pf.SS;
if pf.r.antipodal
  CS = CS.properGroup;
  SS = SS.properGroup;
end

% generate discretization of orientation space
if pf.allR{1}.isOption('resolution')
  res = pf.allR{1}.resolution;
else
  res = 5*degree;
end
res = get_option(varargin,'resolution',res);
S3G = equispacedSO3Grid(CS,SS,'resolution',res);

% zero range method
if check_option(varargin,{'ZR','zero_range'}), S3G = zeroRange(pf,S3G,varargin{:});end

% get kernel
kw = get_option(varargin,{'HALFWIDTH','KERNELWIDTH'},S3G.resolution,'double');
psi = get_option(varargin,'kernel',...
  deLaValeePoussinKernel('halfwidth',kw),'kernel');

% get other options
iter_max = int32(get_option(varargin,'ITER_MAX',...
  getMTEXpref('ITER_MAX',15),'double'));
iter_min = int32(get_option(varargin,'ITER_MIN',10,'double'));

c0 = get_option(varargin,'C0',...
	1/sum(length(S3G))*ones(sum(length(S3G)),1));


% ----------------- prepare for calling calcODF.c -------------------------

% calculate gh
gh = symmetrise(S3G).' * pf.h; % S3G x SS x CS x h
gh = [gh.rho(:),gh.theta(:)].' /2 /pi;

% extract kernel Fourier coefficents
A = psi.A;
if pf.allR{1}.antipodal
  A(2:2:end) = 0;
else
  warning('MTEX:missingFlag','Flag HEMISPHERE not set in PoleFigure data!');
end;
bw = min(get_option(varargin,'bandwidth',length(A)),length(A));
A = A(1:bw);

% detect superposed pole figures
lh = int32(cellfun('length',pf.c)*length(CS)*length(SS));
refl = cell2mat(pf.c);

% arrange Pole figure data
P  = max(0,pf.intensities); % ensure non negativity
lP = int32(cellfun('prodofsize',pf.allI));
r = [pf.r.rho(:),pf.r.theta(:)].' /2/pi;

% normalize very different polefigures
mm = max(pf.intensities(:));

for i = 1:pf.numPF
  if mm > 5*max(pf.allI{i}(:))
    pf.allI{i} = pf.allI{i} * mm/5/max(pf.allI{i}(:));
  end
end

% compute quadrature weights
w = [];
if ~check_option(varargin,'b')
  for i = 1:pf.numPF
    ww = calcQuadratureWeights(pf.allR{i});
    w = [w;ww(:)]; %#ok<AGROW>
  end
  varargin = set_option(varargin,'WEIGHTS');
end

% calculate flags
CW_flags = {{'WEIGHTS',0},{'REGULARISATION',1},...
  {'SAVE_ODF',5},{'RP_VALUES',6},{'FORCE_ITER_MAX',7},{'ODF_TEST',8}};
flags = calc_flags(varargin,CW_flags);

% call c-routine
vdisp('Call c-routine',varargin{:});

[c,alpha] = call_extern('pf2odf',...
  'INTERN',lP,lh,refl,iter_max,iter_min,flags,...
  'EXTERN',P,r,gh,A,c0,w,...
  char(extract_option(varargin,'silent')));
vdisp(['required time: ',int2str(toc),'s'],varargin{:});

% return ODF
odf = unimodalODF(S3G,psi,'weights',c./sum(c));

if check_option(varargin,'noGhostCorrection'), return;end

% ------------------ ghost correction -----------------------------------

% determine phon
phon = 1;
for ip = 1:pf.numPF
  phon = min(phon,...
    quantile(max(0,pf.allI{ip}(:)),0.01)./alpha(ip));
end

if phon > 0.99
  odf = uniformODF(CS,SS);
  return
elseif phon > 0.1
  vdisp('ghost correction',varargin{:});
  vdisp(['calculate with fixed background ',xnum2str(phon)],varargin{:});
else
  return
end

% subtract uniform portion from intensities
for ip = 1:pf.numPF
  pf.allI{ip} = pf.allI{ip} - alpha(ip) * phon;
end
P = max(0,pf.intensities(:)); %no negative values !

c0 = (1-phon)/length(S3G)*ones(length(S3G),1);

% calculate new ODF
[c,alpha] = call_extern('pf2odf',...
  'INTERN',lP,lh,refl,phon,iter_max,iter_min,flags,...
  'EXTERN',P,r,gh,A,c0,w,char(extract_option(varargin,'silent')));

% return ODF
odf = phon * uniformODF(CS,SS) + ... 
  (1-phon) * unimodalODF(S3G,psi,'weights',c./sum(c));

end
