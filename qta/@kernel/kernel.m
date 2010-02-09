function K = kernel(name,varargin)
% constructor
%
%% Description
% The constructor *kernel* defines a @kernel object given the name 
% of the kernel and its halfwidth beta or its free parameter kappa.
% A second posibility is to define the kernel by its Fourier 
% coefficients. A @kernel object is needed when defining a @ODF.
%
%% Input
%  kernel name - string
%
%% Options
%  PARAMETER - kappa (double)
%  HALFWIDTH - beta  (double)
%  FOURIER   - AL    (double)
%  BANDWIDTH - L     (int32)
%
% supported kernel:
% Laplace, Abel Poisson, de la Vallee Poussin, von Mises Fisher,
% fibre von Mises Fisher, Square Singularity, Gauss Weierstrass,
% Dirichlet, local, Fourier, bump, user
%
%% See also
% ODF_index kernel/gethw unimodalODF uniformODF
       
kernels = {'Laplace','Abel Poisson','de la Vallee Poussin',...
    'von Mises Fisher','fibre von Mises Fisher','Square Singularity',...
    'Gauss Weierstrass','local','Dirichlet','Fourier','bump','user','Jackson'};

if nargin == 0
  
  K.name = [];
  K.A    = [];
  K.p1   = 0;
  K.K    = [];
  K.RK   = [];
  K.RRK  = [];
  K.hw   = 0;
  K = class(K,'kernel');
  return;
  
elseif isa(name,'char') && strcmpi(name,'names')
  
  K = kernels;
  return
  
elseif isa(name,'kernel')
  
  K = name; return;
  
elseif ~isa(name,'char')
  
  error('first parameter should be char');
  
elseif ~any(strcmpi(name,kernels))
  
  error(sprintf(['unknown kernel: "',name,'".\nAvailable kernels are: \n',...
    'Laplace, \n',...
    'Abel Poisson, \n',...
    'de la Vallee Poussin, \n',...
    'von Mises Fisher, \n',...
    'fibre von Mises Fisher, \n',...
    'Square Singularity, \n',...
    'Gauss Weierstrass, \n',...
    'local, \n',...
    'Dirichlet, \n',...
    'Fourier, \nbump, \nuser'])); %#ok<SPERR>
  
end
    
if check_option(varargin,'HALFWIDTH')
  hw = get_option(varargin,'HALFWIDTH');
  p = hw2p(name,hw);
elseif length(varargin)>=1
  p = varargin{1};
else
  error('Missing argument! You have to specify either the halfwidth of the kernel function or the kernel parameter');
end

L = get_option(varargin,'BANDWIDTH',100*(1+9*~strcmpi(name,'bump')));

K.name = name;
K.A = construct_A(name,p,L);
K.p1 = p;
K.K = construct_K(name,p,K.A);
K.RK = construct_RK(name,p,K.A);
K.RRK = construct_RRK(name,p,K.A);
if  exist('hw', 'var')
  K.hw = hw;
else
  K.hw = p2hw(name,p);
end
K = class(K,'kernel');
