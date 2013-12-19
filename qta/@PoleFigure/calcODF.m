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
%% Input
%  pf - @PoleFigure
%
%% Options
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
%% Flags
%  ZERO_RANGE        - apply zero range method (default = )
%  NOGHOSTCORRECTION - omit ghost correction
%  ENSURE_DESCENT - stop iteration whenever no procress if observed
%  FORCE_ITER_MAX - allway go until ITER_MAX
%  RP_VALUES      - calculate RP values during iteration
%  ODF_TEST       - for testing only
%  SILENT         - no output
%
%% Output
%  odf    - reconstructed @ODF
%  alpha  - scaling factors, calculated during reconstruction
%
%% See also
% PoleFigure2odf ODF_demo PoleFigureSimulation_demo
% loadPoleFigure ImportPoleFigureData examples_index

tic

vdisp('------ MTEX -- PDF to ODF inversion ------------------',varargin{:})

%% ------------------- get input--------------------------------------------
CS = pf(1).CS; SS = pf(1).SS;

S3G = get_option(varargin,'RESOLUTION',get(pf,'resolution'),{'double','SO3Grid'});
if ~isa(S3G,'SO3Grid'), S3G = SO3Grid(S3G,CS,SS); end
if check_option(varargin,'zero_range'), S3G = zero_range(pf,S3G,varargin{:});end
if ~(CS == get(S3G,'CS') && SS == get(S3G,'SS'))
    qwarning('Symmetry of the Grid does not fit to the given Symmetrie');
end

kw = get_option(varargin,{'HALFWIDTH','KERNELWIDTH'},get(S3G,'resolution'),'double');
psi = get_option(varargin,'kernel',...
  kernel('de la Vallee Poussin','HALFWIDTH',kw),'kernel');

iter_max = int32(get_option(varargin,'ITER_MAX',...
  getMTEXpref('ITER_MAX',15),'double'));
iter_min = int32(get_option(varargin,'ITER_MIN',10,'double'));

c0 = get_option(varargin,'C0',...
	1/sum(numel(S3G))*ones(sum(numel(S3G)),1));


%% ----------------- prepare for calling calcODF.c -------------------------
%% -------------------------------------------------------------------------

% calculate gh
gh = symmetrise(S3G).' * get(pf,'h'); % S3G x SS x CS x h
[ghtheta,ghrho] = polar(gh(:));
gh = [ghrho.';ghtheta.'] /2 /pi;
clear ghtheta; clear ghrho;

% extract kernel Fourier coefficents
A = getA(psi);
if check_option(get(pf(1),'r'),'antipodal')
  A(2:2:end) = 0;
else
  warning('MTEX:missingFlag','Flag HEMISPHERE not set in PoleFigure data!');
end;
bw = min(get_option(varargin,'bandwidth',length(A)),length(A));
A = A(1:bw);

% detect superposed pole figures
lh = int32(zeros(1,length(pf)));
for i=1:length(pf)
	lh(i) = int32(length(get(pf(i),'h'))*length(CS)*length(SS));
end
refl = get(pf,'c');

% arrange Pole figure data
P  = max(0,get(pf,'data')); % ensure non negativity
lP = int32(GridLength(pf));
[rtheta,rrho] = polar(get(pf,'r'));
r = [reshape(rrho,1,[]);reshape(rtheta,1,[])]/2/pi;
clear rtheta;clear rrho;


%% ---------- normalize very different polefigures --------------------
mm = max(max(pf));

for i = 1:numel(pf)

  if mm > 5*max(pf(i)), pf(i) = pf(i) * mm/5/max(pf(i));end

end

%% ----------------------- WHEIGHTS ----------------------------------

% compute quadrature weights
w = [];
if ~check_option(varargin,'NoQuadratureWeights')
  for i = 1:numel(pf)
    ww = calcQuadratureWeights(pf(i).r);
    w = [w;ww(:)]; %#ok<AGROW>
  end
  varargin = set_option(varargin,'WEIGHTS');
end

% ------------------- REGULARIZATION -----------------------------------
if check_option(varargin,'REGULARISATION')
  lambda = get_option(varargin,'REGULARISATION',0.1);
  RM = sum(lP) / length(c0) * lambda * RegMatrix(psi,S3G);
  RM = spfun(@sqrt,RM);
else
  RM = [];
end

%% --------------------- ODF testing ----------------------------------
orig = get_option(varargin,'ODF_TEST',[]);
test_S3G = get_option(varargin,'TEST_GRID',S3G);
if isempty(orig)
	evaldata = [];
	evalmatrix = [];
else
	if check_option(varargin,'TEST_GRID')
		evalmatrix = K(psi,test_S3G,S3G,CS,SS);
	else
		evalmatrix = K(psi,S3G,[],CS,SS);
	end
  evaldata = eval(orig,test_S3G,'EXACT'); %#ok<*GTARG>
end

%% --------------------- CALCULATE FLAGS ---------------------------------
CW_flags = {{'WEIGHTS',0},{'REGULARISATION',1},...
  {'SAVE_ODF',5},{'RP_VALUES',6},{'FORCE_ITER_MAX',7},{'ODF_TEST',8}};
flags = calc_flags(varargin,CW_flags);

%% -------------------- call c-routine -----------------------------------
% -----------------------------------------------------------------------

vdisp('Call c-routine',varargin{:});

comment = get_option(varargin,'comment',...
  ['ODF recalculated from ',get(pf,'comment')]);

[c,alpha] = call_extern('pf2odf',...
  'INTERN',lP,lh,refl,iter_max,iter_min,flags,...
  'EXTERN',P,r,gh,A,c0,w,RM,evaldata,evalmatrix,...
  char(extract_option(varargin,'silent')));
vdisp(['required time: ',int2str(toc),'s'],varargin{:});

% return ODF
odf = 1/sum(c)*ODF(S3G,c,psi,CS,SS,'comment',comment);

if check_option(varargin,'noGhostCorrection'), return;end

% ------------------ ghost correction -----------------------------------
% -----------------------------------------------------------------------

% determine phon
phon = 1;
for ip = 1:length(pf)
  phon = min(phon,quantile(max(0,get(pf(ip),'data')),0.01)./alpha(ip));
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


% subtract from intensities
P = [];
for ip = 1:length(pf)
  P = [P;reshape(get(pf(ip),'data'),[],1)-alpha(ip)*phon]; %#ok<AGROW>
end
P = max(0,P); %no negative values !

c0 = (1-phon)/numel(S3G)*ones(numel(S3G),1);

% calculate new ODF
[c,alpha] = call_extern('pf2odf',...
  'INTERN',lP,lh,refl,phon,iter_max,iter_min,flags,...
  'EXTERN',P,r,gh,A,c0,w,RM,evaldata,evalmatrix,...
  char(extract_option(varargin,'silent')));

% return ODF
odf(1) = phon * uniformODF(CS,SS,'comment',comment);
odf(1+(phon>0)) = (1-phon)/sum(c)*ODF(S3G,c,psi,CS,SS,'comment',comment);

end


function vdisp(s,varargin)
if ~check_option(varargin,'silent'), disp(s);end
end
