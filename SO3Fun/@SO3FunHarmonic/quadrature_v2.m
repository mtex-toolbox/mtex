function SO3F = quadrature_v2(f, varargin)
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature_v2(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature_v2(f)
%   SO3F = SO3FunHarmonic.quadrature_v2(f, 'bandwidth', bandwidth)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes  - @rotation, @orientation
%  f - function handle in @orientation (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth      - minimal harmonic degree (default: 64)
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights
%

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan')
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  return
end

bw = get_option(varargin,'bandwidth', 64);


% 1) compute/get weights and values for quadrature

if isa(f,'SO3Fun')
  SLeft = f.SLeft; SRight = f.SRight;
  f = @(v) f.eval(v);
end

if isa(f,'function_handle')
  if check_option(varargin,'gauss')
    % possilbly use symmetries and evaluate in fundamental region
    [nodes, W] = quadratureSO3Grid(2*bw,'gauss',SRight,SLeft,'complete');
  else
      [nodes,W] = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft,'complete');
    varargin{end+1} = 'ClenshawCurtis';
  end
  values = f(nodes(:));
else
  nodes = f(:);
  values = varargin{1};
  W = get_option(varargin,'weights',1);
  
  if length(nodes)>1e7 && length(values) == length(nodes) && length(W)==1
    % TODO: use a regular grid here and a faster search 
    % TODO: nodes have to be orientation to use nodes.CS . Does the following work correctly?
    % if isa(nodes,'rotation'), orientation(nodes,crystalSymmetry); end
    n2 = equispacedSO3Grid(nodes.CS,'resolution',0.5*degree);
    id = find(n2,nodes);
    values = accumarray(id,values,[length(n2),1]);
    
    id = values>0;
    nodes = reshape(n2.subGrid(id),[],1);
    values = values(id);
    nodes.antipodal = f.antipodal;
  end

  if isa(nodes,'orientation')
    SRight = nodes.CS; SLeft = nodes.SS;
  else
    [SRight,SLeft] = extractSym(varargin);
  end
end

if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end


% 2) Inverse trivariate NFFT/FFT and representation based wigner transform

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% initialize nfft plan
if isempty(plan) && ~check_option(varargin,'ClenshawCurtis')

  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*bw+2;
  FN = ceil(1.5*NN);
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
  fftw_flag = int8(64);
  plan = nfftmex('init_guru',{3,NN,NN,NN,length(nodes),FN,FN,FN,4,int8(0),fftw_flag});

  % set rotations as nodes in plan
  nfftmex('set_x',plan,(Euler(nodes,'nfft').')/(2*pi));
  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

s = size(values);
values = reshape(values, length(nodes), []);
num = size(values, 2);

fhat = zeros(deg2dim(bw+1), num);
for index = 1:num
  
  % use trivariate inverse equispaced fft in case of Clenshaw Curtis quadrature 
  % and nfft otherwise 
  if check_option(varargin,'ClenshawCurtis')

    ghat = ifftn( W.* reshape(values(:, index),size(W)) ,[2*bw+2,4*bw,2*bw+2]);
    ghat = ifftshift(ghat);
    ghat = 16*bw*(bw+1)^2 * ghat(2:end,bw+1:3*bw+1,2:end);

  else
    
    % adjoint nfft
    nfftmex('set_f', plan, W(:) .* values(:, index));
    nfftmex('adjoint', plan);
    % adjoint fourier transform
    ghat = nfftmex('get_f_hat', plan);
    ghat = reshape(ghat,2*bw+2,2*bw+2,2*bw+2);
    ghat = ghat(2:end,2:end,2:end);

  end

  % shift rotational grid
  [~,k,l] = meshgrid(-bw:bw,-bw:bw,-bw:bw);
  ghat = (1i).^(l-k).*ghat;

  % set flags and symmetry axis
  flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
  if sum(abs(imag(values(:,index)))) < (1e-10)*sum(abs(real(values(:,index))))  % real valued
    flags = flags+2^2;
  end
  if check_option(varargin,'antipodal') || (isa(nodes,'orientation') && nodes.antipodal) % antipodal
    flags = flags+2^3;
  end
  sym = [min(SRight.multiplicityPerpZ,2),SRight.multiplicityZ,...
         min(SLeft.multiplicityPerpZ,2),SLeft.multiplicityZ];
  
  % use adjoint representation based coefficient transform
  fhat(:,index) = adjoint_representationbased_coefficient_transform(bw,ghat,flags,sym);
  fhat(:,index) = sym_aRBWT(fhat(:,index),flags,sym);
  %fhat(:,index) = adjoint_representationbased_coefficient_transform_old(bw,ghat,flags);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~check_option(varargin, 'ClenshawCurtis')
  nfftmex('finalize', plan);
end

try
  fhat = reshape(fhat, [deg2dim(bw+1) s(2:end)]);
end

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);
SO3F.bandwidth = bw;

end
