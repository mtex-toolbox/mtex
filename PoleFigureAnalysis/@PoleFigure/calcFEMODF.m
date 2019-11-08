function [odf,alpha] = calcFEMODF(pf,varargin)
% PDF to ODF inversion
%
% *calcFEMODF* is one of the main function of the MTEX toolbox.
% It estimates an ODF from given Polefigure intensities by
% <PoleFigure2ODF.html fitting an ODF that consists of a large number of unimodal ODFs to the data>.
% It does so by minimizing a least squares functional. The command
% *calcODF* supports <PoleFigure2ODFGhostCorrection.html automatic ghost correction> and
% <PoleFigureDubna.html the zero range method>.
% The function *calcFEMODF* has several options to control convergence,
% resolution, smoothing, etc. See below for a complete description.
%
%
% Input
%  pf - @PoleFigure
%
% Options
%  resolution     - localization grid for the ansatz fucntions (default = 3/2 resolution(pf))
%  iterMax        - maximum number of iterations (default = 11)
%  regularisation - weighting coefficient lambda (default = 0)
%
% Flags
%  zeroRange         - apply zero range method (default = )
%  noGhostCorrection - omit ghost correction
%
% Output
%  odf    - reconstructed @FEMODF
%  alpha  - scaling factors, calculated during reconstruction
%
% See also
% PoleFigure2odf ODF_demo PoleFigureSimulation_demo
% PoleFigure.load ImportPoleFigureData examples_index

tic
vdisp('------ MTEX -- PDF to ODF inversion ------------------',varargin{:})

% ------------------- get input--------------------------------------------

CS = pf.CS; SS = pf.SS;

% generate FEM discretization of orientation space
res = get_option(varargin,'resolution',pf.resolution);
%ori = equispacedSO3Grid(CS,SS,'resolution',min(res,10*degree));
%DSO3 = DelaunaySO3(ori);
DSO3 = varargin{1};

% zero range method - TODO
%if check_option(varargin,'zero_range'), S3G = zero_range(pf,S3G,varargin{:});end

vdisp('Setting up matrices',varargin{:});
% compute matrices
for ipf = 1:length(pf)  
  h = pf(ipf).h;
  vdisp(char(h),varargin{:});
  M{ipf} = sparse(length(pf(ipf).r),length(DSO3));
  for ih = 1:length(h)
    M{ipf} = M{ipf} + pf(ipf).c(ih) .* DSO3.pdfMatrix(h(ih),pf(ipf).r,varargin{:});
  end
  
  b{ipf} = pf(ipf).intensities(:);
end

M = vertcat(M{:});
b = vertcat(b{:});

vdisp(['starting solver'],varargin{:});
vdisp(['matrix is ' sizestr(M) ],varargin{:});
% solve the linear system of equation
c = lsqnonneg(M,b);
%c = M \ b;


% set up FEMODF
odf = femODF(DSO3,'weights',c);

end
