function [odf,alpha] = calcODF(pf,varargin)
% PDF to ODF inversion
%
% *calcODF* is one of the main function of the MTEX toolbox.
% It estimates an ODF from given Polefigure intensities by 
% <odf_estimation.html fitting an ODF that consists of a large number of unimodal ODFs to the data>.
% It does so by minimizing a least squares functional. The command
% *calcODF* supports <ghost_demo.html automatic ghost correction> and 
% <dubna_demo.html the zero range method>.
% The function *calcODF* has several options to control convergence,
% resolution, smoothing, etc. See belov for a complete description.
%
%% Syntax
%  [odf,alpha] = calcODF(pf,<options>)
%
%% Input
%  pf - @PoleFigure 
% 
%% Options
%  BACKGROUND       - the background radiation (default = 1)
%  NO_BACKGROUND    - pure L^2 minimization
%  KERNEL           - the ansatz functions (default = de la Vallee Poussin)
%  KERNELWIDTH      - halfwidth of the ansatz functions (default = 2/3 * resolution)
%  RESOLUTION       - localization grid for the ansatz fucntions (default = 3/2 resolution(pf))
%  BANDWIDTH        - bandwidth of the ansatz functions (default = max)
%  ITER_MAX         - maximum number of iterations (default = 11)
%  ITER_MIN         - minimum number of iterations (default = 5)
%  REGULARIZATION   - weighting coefficient lambda (default = 0)
%  ODF_SAVE         - save ODF simultanously 
%  C0               - initial guess (default = [1 1 1 1 ... 1])
%  ZERO_RANGE       - apply zero range method (default = )
%  GHOST_CORRECTION - apply ghost correction (default = )
%
%% Flags
%  ENSURE_DESCENT - stop iteration whenever no procress if observed
%  FORCE_ITER_MAX - allway go until ITER_MAX
%  RP_VALUES      - calculate RP values during iteration
%  ODF_TEST       - for testing only
%  SILENT         - no output
%
%% Output
%  odf    - reconstructed @ODF
%  alpha  - scaling factors - calculated during reconstruction
%
%% See also
% odf_estimation ODF_demo PoleFigureSimulation_demo ODF_calculations_index
% loadPoleFigure interfaces_index examples_index 

tic

vdisp('------ MTEX -- PDF to ODF inversion ------------------',varargin{:})

% ------------------- get input--------------------------------------------
CS = pf(1).CS; SS = pf(1).SS;

S3G = get_option(varargin,'RESOLUTION',getResolution(pf)*3/2,{'double','SO3Grid'});
if ~isa(S3G,'SO3Grid'), S3G = SO3Grid(S3G,CS,SS); end
if check_option(varargin,'zero_range'), S3G = zero_range(pf,S3G,varargin{:});end
if ~(CS == getCSym(S3G) && SS == getSSym(S3G))
    qwarning('Symmetry of the Grid does not fit to the given Symmetrie');
end

kw = get_option(varargin,'KERNELWIDTH',getResolution(S3G),'double');
psi = get_option(varargin,'kernel',...
  kernel('de la Vallee Poussin','HALFWIDTH',kw),'kernel');

global mtex_maxiter;
iter_max = int32(get_option(varargin,'ITER_MAX',mtex_maxiter,'double'));
iter_min = int32(get_option(varargin,'ITER_MIN',iter_max/4,'double'));

c0 = get_option(varargin,'C0',...
	1/sum(GridLength(S3G))*ones(sum(GridLength(S3G)),1));




% ----------------- prepare for calling calcODF.c -------------------------
% -------------------------------------------------------------------------

% calculate gh
h = geth(pf);
%[h,lh] = symetriceVec(CS,geth(pf),'REDUCED');
g = SS*reshape(quaternion(S3G),1,[]); % SS x S3G
g = reshape(g.',[],1);                % S3G x SS
g = reshape(g*CS,[],1);               % S3G x SS x CS
gh = g * h;                           % S3G x SS x CS x h
clear g;
[ghtheta,ghrho] = vec2sph(reshape(gh,[],1));
gh = [reshape(ghrho,1,[]);reshape(ghtheta,1,[])]/2/pi;
clear ghtheta; clear ghrho;

% extract kernel Fourier coefficents
A = getA(psi);
if check_option(getr(pf(1)),'reduced')
  A(2:2:end) = 0; 
else
  warning('Flag HEMISPHERE not set in PoleFigure data!');
end;
bw = min(get_option(varargin,'bandwidth',length(A)),length(A));
A = A(1:bw);

% detect superposed pole figures
lh = int32(zeros(1,length(pf)));
for i=1:length(pf)
	lh(i) = int32(length(geth(pf(i)))*length(CS)*length(SS));	
end
refl = getc(pf);

% arrange Pole figure data
P  = getdata(pf);
lP = int32(GridLength(pf));
[rtheta,rrho] = polar(getr(pf));
r = [reshape(rrho,1,[]);reshape(rtheta,1,[])]/2/pi;
clear rtheta;clear rrho;


% ----------------------- WHEIGHTS ----------------------------------
if check_option(pf(1).options,'BACKGROUND') && ...
    ~check_option(varargin,'NO_BACKGROUND')
  w = sqrt(1./sqrt(max(P+getbg(pf),0.0001)));
  varargin = set_option(varargin,'BACKGROUND');
elseif ~check_option(varargin,'NO_BACKGROUND') 
  w = sqrt(1./sqrt(max(P+get_option(varargin,'BACKGROUND',10),0.0001)));
  varargin = set_option(varargin,'BACKGROUND');
else
  w = [];
end

% ------------------- REGULARIZATION -----------------------------------
if check_option(varargin,'REGULARISATION')
  lambda = get_option(varargin,'REGULARISATION',0.1);
  RM = sum(lP) / length(c0) * lambda * RegMatrix(psi,S3G);
  RM = spfun(@sqrt,RM);
else
  RM = [];
end

% --------------------- ODF testing ----------------------------------
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
  evaldata = eval(orig,test_S3G,'EXACT');
end

% --------------------- CALCULATE FLAGS ---------------------------------
CW_flags = {{'BACKGROUND',0},{'REGULARISATION',1},...
  {'SAVE_ODF',5},{'RP_VALUES',6},{'FORCE_ITER_MAX',7},{'ODF_TEST',8}};
flags = calc_flags(varargin,CW_flags);

% -------------------- call c-routine -----------------------------------
% -----------------------------------------------------------------------

vdisp('Call c-routine',varargin{:});

comment = get_option(varargin,'comment',...
  ['ODF recalculated from ',getcomment(pf)]);

global mtex_path;

[c,alpha] = run_linux([mtex_path,'/c/bin/pf2odf'],...
  'INTERN',lP,lh,refl,iter_max,iter_min,flags,...
  'EXTERN',P,r,gh,A,c0,w,RM,evaldata,evalmatrix,...
  char(extract_option(varargin,'silent')));
vdisp(['required time: ',int2str(toc),'s'],varargin{:});

% return ODF
odf = 1/sum(c)*ODF(S3G,c,psi,CS,SS,'comment',comment);

if ~check_option(varargin,'ghost_correction'), return;end

% ------------------ ghost correction -----------------------------------
% -----------------------------------------------------------------------

vdisp('ghost correction',varargin{:});

% determine phon
phon = 1;
for ip = 1:length(pf)
  phon = min(phon,quantile(getdata(pf(ip)),0.01)./alpha(ip));
end

if phon > 0.05
  vdisp(['calculate with fixed background ',xnum2str(phon)],varargin{:});
else
  vdisp('No phon! No ghost correction possible!',varargin{:});
  return
end

% subtract from intensities
P = [];
for ip = 1:length(pf)
  P = [P,getdata(pf(ip))-alpha(ip)*phon];
end

c0 = (1-phon)/sum(GridLength(S3G))*ones(sum(GridLength(S3G)),1);

% calculate new ODF
[c,alpha] = run_linux([mtex_path,'/c/bin/pf2odf'],...
  'INTERN',lP,lh,refl,phon,iter_max,flags,...
  'EXTERN',P,r,gh,A,c0,w,RM,evaldata,evalmatrix,...
  char(extract_option(varargin,'silent')));

% return ODF
odf(1) = phon * uniformODF(CS,SS,'comment',comment);
odf(1+(phon>0)) = (1-phon)/sum(c)*ODF(S3G,c,psi,CS,SS,'comment',comment);

end


function vdisp(s,varargin)
if ~check_option(varargin,'silent'), disp(s);end
end
