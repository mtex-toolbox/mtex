function SO3F = adjoint(rot,values, varargin)
% Compute the adjoint SO(3)-Fourier/Wigner transform of given evaluations 
% on specific nodes.
%
% This method uses an adjoint trivariate nfft/fft and an adjoint coefficient 
% transform which is based on a representation property of the Wigner-D 
% functions.
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.adjointNFSOFT|.
%
% Syntax
%   SO3F = SO3FunHarmonic.adjoint(rot,values)
%   SO3F = SO3FunHarmonic.adjoint(rot,values,'bandwidth',32,'weights',w)
%
% Input
%  rot  - @quadratureSO3Grid, @rotation, @orientation, @SO3Grid
%  values - double
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree (default: 64)
%  weights   - quadrature weights
%  cutOffParameter - NFFT window cutoff m (default: 6 for few nodes on a large lattice, 4 otherwise)
%  oversampling - NFFT oversampling factor sigma (default: 1.25 for few nodes on a large lattice, 2 otherwise)
%
% Flags
%  'nfsoft'            - use (mostly slower) NFSOFT algorithm
%  'silent'            - suppress transform progress output
%  'directComputation' - direct evaluation of Fourier sums (no nfft)
%  'gridded'           - round the rotations onto a regular Clenshaw Curtis
%                        quadrature grid and use the plain FFT instead of
%                        the NFFT (fast approximation for many rotations)
%  'createPlan'        - NFFT3-Flags
%  'keepPlan'          - NFFT3-Flags
%  'deletePlan'        - NFFT3-Flags
%
% See also
% SO3FunHarmonic/quadrature SO3FunHarmonic/adjointNFSOFT
% SO3FunHarmonic/approximate SO3FunHarmonic/interpolate



% Use NFSOFT of nfft3 toolbox
if check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.adjointNFSOFT(rot,values,varargin{:});
  return
end

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan') 
  if isempty(keepPlanNFFT), return, end
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  SO3F=[];
  return
end


% vector valued functions
% if length(rot)~=numel(values)
%   s = size(values); s = s(2:end);
%   values = reshape(values,length(rot),[]);
%   SO3FunHarmonic.adjoint(rot,values(:,1),'createPlan',varargin{:});
%   SO3F = [];
%   for ind = 1:prod(size(values,2))
%     G = SO3FunHarmonic.adjoint(rot,reshape(values(:,ind),size(rot)),'keepPlan',varargin{:});
%     SO3F = [SO3F,G];
%   end
%   SO3FunHarmonic.adjoint(rotation.id,1,'killPlan');
%   SO3F = reshape(SO3F, s);
%   return
% end

% -------------- (1) get weights and values for quadrature ----------------

sz = size(values);
len = prod(sz(2:end)); % vector valued case
values = reshape(values,[],len);

if isa(rot,'orientation')
  SRight = rot.CS; SLeft = rot.SS;
  if rot.antipodal, rot.antipodal = 0; varargin{end+1} = 'antipodal'; end
else
  [SRight,SLeft] = extractSym(varargin);
  rot = orientation(rot,SRight,SLeft);
end

% a non finite node makes nfft write outside its buffers and crash MATLAB - it
% cannot be removed from a plan, so zero its value and replace its coordinates
% below; a quadratureSO3Grid is finite by construction and is not tested
if isa(rot,'quadratureSO3Grid')
  isBadNode = false;
else
  isBadNode = ~(isfinite(rot.a) & isfinite(rot.b) & isfinite(rot.c) & isfinite(rot.d));
  isBadNode = isBadNode(:);
  if any(isBadNode)
    warning('There are non finite nodes. They are ignored.')
    values(isBadNode,:) = 0;
  end
end

% ------ approximate adjoint by rounding onto a regular grid + FFT --------
% For many rotations it is much cheaper to round them onto the nearest
% nodes of a regular Clenshaw Curtis quadrature grid, accumulate their
% values there and compute the adjoint transform by the plain FFT below
% instead of the NFFT. The rounding error is at most half the grid spacing,
% i.e. pi/(2N) in the second Euler angle.
if check_option(varargin,'gridded') && ~isa(rot,'quadratureSO3Grid')

  N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));

  % quadrature weights are just factors of the values
  W = get_option(varargin,'weights',1);
  values = W(:) .* values;

  % Use a grid with trivial symmetries: the point measure given by the
  % rotations has no grid symmetry to exploit (the symmetrisation of the
  % result remains the task of the caller, as for the NFFT branch below).
  % The grid is oversampled to reduce the rounding error - the transform
  % is computed at bandwidth NG and truncated to N afterwards (by the
  % 'bandwidth' option in the constructor). The cap bounds the memory
  % of the FFT over the full Euler angle tensor.
  NG = min(2*N, max(N,128));
  SO3G = quadratureSO3Grid(NG,'ClenshawCurtis',crystalSymmetry,specimenSymmetry);

  % accumulate the values at the nearest grid nodes - a non finite node has
  % no nearest node, but its value is zero, so any index will do
  if any(isBadNode)
    id = ones(length(rot),1);
    id(~isBadNode) = find(SO3G,rot(~isBadNode));
  else
    id = find(SO3G,rot(:));
    id = id(:);
  end
  v = zeros(length(SO3G),len);
  for k = 1:len
    v(:,k) = accumarray(id,values(:,k),[length(SO3G) 1]);
  end

  % the FFT based adjoint multiplies by the quadrature weights of all
  % duplicated full-grid entries - compensate for this so that exactly the
  % accumulated point masses enter the transform
  sumW = accumarray(SO3G.iuniqueGrid(:),SO3G.weights(:),[length(SO3G) 1]);
  v = v ./ sumW;

  % antipodal has to wait until the true symmetries are restored - on the
  % trivial symmetry grid result it would fail (CS and SS do not coincide)
  isAntipodal = check_option(varargin,'antipodal');
  varargin = delete_option(varargin,'antipodal');
  varargin = delete_option(varargin,'weights',1);
  varargin = delete_option(varargin,'gridded');
  SO3F = SO3FunHarmonic.adjoint(SO3G,v,varargin{:});

  % restore the symmetries of the input rotations and project onto the
  % symmetric subspace, as the constructor does below
  SO3F.CS = SRight; SO3F.SS = SLeft;
  SO3F = symmetrise(SO3F);
  SO3F.antipodal = isAntipodal;
  SO3F = reshape(SO3F,sz(2:end));
  return
end

if isa(rot,'quadratureSO3Grid')
  %  TODO: Multivariate quadratureSO3Grid
  N = rot.bandwidth;
  if strcmp(rot.scheme,'ClenshawCurtis')
    values = reshape(values(rot.iuniqueGrid,:),[size(rot.iuniqueGrid) size(values,2)]);
    W = rot.weights;
  else % use unique grid in NFFT in case of Gauss-Legendre quadrature
    if SRight.multiplicityPerpZ*SLeft.multiplicityPerpZ == 1
      GC = 1;
    else
      GC = groupcounts(rot.iuniqueGrid(:));
    end
    W = rot.weights(rot.ifullGrid).*GC;
  end
else
  N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));
  W = get_option(varargin,'weights',1);
end

% check for Inf-values (quadrature fails)
if any(isinf(values(:)))
  ind = isinf(values);
  m = max( abs(values(~ind)) ,[],'all')*1e+10;
  values(ind) = sign(values(ind)) .* m;
  warning(['There are poles at some quadrature nodes. They are set to +-',num2str(m,3),'.'])
  % error('There are poles at some quadrature nodes.')
end
if any(isnan(values(:)))
  warning('There are Nan values in some nodes. They are set to 0.')
  values(isnan(values)) = 0;
end

if isempty(rot)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end

% -------------------- (2) Adjoint trivariate NFFT/FFT --------------------

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% only the multiples of the rotational symmetries around the Z-axis are
% needed, which the Wigner transform reads from a smaller lattice
isCC = isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis');
folded = ~check_option(varargin,'directComputation');
useNFFT = folded && ~isCC;
if folded

  NN = 2*N+2;
  rZ = [1,1];
  if (SRight.id~=0 && SLeft.id~=0) || isCC, rZ = [SRight.multiplicityZ,SLeft.multiplicityZ]; end
  [ind1,s3] = foldZ(-(N+1):N,rZ(1),0);
  [ind3,s1] = foldZ(-(N+1):N,rZ(2),0);
  szG = [2*ceil(numel(ind1)/2),NN,2*ceil(numel(ind3)/2)];

end
% TODO: Probably use limit 1e-5 because this is precision m of nfft
isReal = isreal(values) || isalmostreal(values,'precision',10,'norm',1);
if useNFFT

  % for real values the Wigner transform reads only the orders k <= 1 of the
  % first dimension - unless the plan is kept for later values
  szN = szG;
  realN = isReal && ~check_option(varargin,{'createPlan','keepPlan'});
  if realN
    [ind1n,s3] = foldZ(-(N+1):1,rZ(1),0);
    szN(1) = 2*ceil(numel(ind1n)/2);
  end

  % the nfft gets the smaller lattice from stretched nodes, and the kept
  % frequencies start at index 0, which shifts them by s against the
  % centered frequencies of the nfft
  [nodes,~,shift] = nfftNodesmex(double(rot.a),double(rot.b),double(rot.c),double(rot.d),rZ([2 1]),[s1 s3]);

  % Real values take the real nfft at -gamma, whose orders k' >= 0 are the
  % orders k = -k' <= 0 of the first dimension, and k = 1 is the conjugate of
  % k = -1 at -j, -l. The third dimension goes to its centered position.
  if realN
    kr = -floor((N+1)/rZ(1));
    lr = (-(N+1)+ind3(1)-1)/rZ(2) + (0:numel(ind3)-1);
    Nl = 2*max(-lr(1),lr(end)+1);
    nR = [Nl,NN,2*(1-kr)];
    nodes(3,:) = mod(-nodes(3,:),1);
  end

end

% initialize nfft plan
if isempty(plan) && useNFFT

  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms,
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly.
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and
  %                         measuring their execution time. This can take some time (often a few seconds).
    fftw_flags = int8(64);
    nfft_flags = 1+2^12+2^10+2^13; % PRE_PHI_HUT | NFFT_OMP_BLOCKWISE_ADJOINT | FFTW_INIT | NFFT_PRUNED_FFT
    % PRE_PSI pays only for a plan that is kept for later functions
    if check_option(varargin,{'createPlan','keepPlan'}), nfft_flags = nfft_flags + 2^4; end
  % window cutoff m and oversampling sigma - see SO3FunHarmonic/eval
    [m,sigma] = nfftParameters(length(rot),szN,varargin{:});
    fftw_size = fftLength(sigma*szN);
  % initialize nfft plan
  if realN
    fftw_size = fftLength(sigma*nR);
    plan = nfftmex('init_guru',{3,nR(1),nR(2),nR(3),length(rot),fftw_size(1),fftw_size(2),fftw_size(3),m,nfft_flags+2^14,fftw_flags});
  else
    plan = nfftmex('init_guru',{3,szN(3),szN(2),szN(1),length(rot),fftw_size(3),fftw_size(2),fftw_size(1),m,nfft_flags,fftw_flags});
  end

  % set rotations as nodes in plan
  nfftmex('set_x',plan,nodes);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNFFT = plan;
  SO3F=[];
  return
end

% set flags and symmetry axis
if SLeft.id==0 || SRight.id==0 % do not use symmetry properties, if symmetries are not standardized
  flags = 2^0;  % use L2-normalized Wigner-D functions
else
  flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
end
if isReal % real valued
  flags = flags+2^2;
end
% two fold axes perpendicular to Z, 2 for one along y and 3 for one along x,
% only fit the samples of the Clenshaw Curtis grid
alongX = @(G) ismember(G.id,3:5) || (ismember(G.id,19:21) && isa(G,'specimenSymmetry')) || ...
  (ismember(G.id,22:24) && isa(G,'crystalSymmetry'));
perpY = @(G) max(1+(G.multiplicityPerpZ~=1),3*alongX(G));
sym = [perpY(SRight),SRight.multiplicityZ,perpY(SLeft),SLeft.multiplicityZ];
if ~isCC || SLeft.id==0 || SRight.id==0 || (SRight.multiplicityPerpZ==1 && SLeft.multiplicityPerpZ==1)
  sym([1,3]) = 1;
end
% if the Z-axes the lattice is folded by make up the whole groups, the result
% is symmetric already
if folded && numProper(SRight) == rZ(1) && numProper(SLeft) == rZ(2)
  varargin{end+1} = 'skipSymmetrise';
end
% the folded lattice has the Z-axis symmetries rZ
symLattice = sym;
if folded, symLattice([2,4]) = rZ; end

% use trivariate inverse equispaced fft in case of Clenshaw Curtis
% quadrature grid and nfft otherwise 
% TODO: Do FFT × NFFT × FFT in case of GaussLegendre-Quadrature
if isCC

  % The grid covers only the fundamental region of the Z-axis symmetries in
  % the first and third Euler angle, so inverse FFTs of its length give
  % exactly the multiples of the symmetries, beta takes the length 4N. Every
  % FFT keeps only the orders the Wigner transform reads - of a real valued
  % function no k > 1 - and the one in beta comes last.
  n = size(W,[1 3]);
  b1 = mod((-(N+1)+ind1-1)/rZ(1),n(1)) + 1;
  if isReal, b1 = b1(1:numel(foldZ(-(N+1):1,rZ(1),0))); end
  b3 = mod((-(N+1)+ind3-1)/rZ(2),n(2)) + 1;
  x = ifft((n(1)*4*N*n(2)) * W .* reshape(values,[size(W),len]),[],1);
  x = ifft(x(b1,:,:,:),[],3);
  x = ifft(x(:,:,b3,:),4*N,2);
  ghat = x(:,mod(-N:N,4*N)+1,:,:);

elseif check_option(varargin,'directComputation')
  % TODO: use symmetries
  
  % Do adjoint nsoft directly by evaluating the sum
  nodes = Euler(rot(:),'nfft').';
  nodes(:,isBadNode) = 0;
  ghat = zeros(2*N+1,2*N+1,2*N+1,len);

  for m = 1:length(rot)
    ghat = ghat + reshape(values(m,:),1,1,1,[]).*exp(1i * ( ...
      (-N:N)*nodes(2,m) ...
      + (-N:N)'*nodes(3,m) ...
      + permute(-N:N,[1,3,2])*nodes(1,m)) );
  end

end

% --------------------- (3) adjoint Wigner transform ----------------------

% the adjoint Wigner transform includes the exact i^(l-k), the adjoint nfft
% goes straight into it
fhat = zeros(deg2dim(N+1),len);
pC = progressCounter(len,varargin{:});
for i=1:len
  if useNFFT && realN
    nfftmex('set_f', plan, double(W(:) .* values(:,i)));
    nfftmex('adjoint', plan);
    h = reshape(nfftmex('get_f_hat', plan),nR(3)/2,NN,Nl);
    g = zeros(szN);
    g(1-kr:-1:1,:,1:numel(ind3)) = h(:,:,lr(1)+Nl/2+(1:numel(ind3)));
    if rZ(1) == 1
      jm = NN+2 - (1:NN); lm = Nl/2+1 - lr;
      ok = jm <= NN; okl = lm >= 1 & lm <= Nl;
      g(2-kr,ok,okl) = conj(h(2,jm(ok),lm(okl)));
    end
  elseif useNFFT
    nfftmex('set_f', plan, double(W(:) .* values(:,i)) .* shift);
    nfftmex('adjoint', plan);
    g = reshape(nfftmex('get_f_hat', plan),szN);
  elseif len > 1
    g = ghat(:,:,:,i);
  else
    g = ghat;
  end
  fhat(:,i) = wignerTrafoAdjointmex(N,double(g),flags+folded*2^5,symLattice);
  pC.show(i);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~isempty(plan)
  nfftmex('finalize', plan);
end

% ------------------- (4) Construct SO3FunHarmonic ------------------------

SO3F = SO3FunHarmonic(fhat,SRight,SLeft,varargin{:});
SO3F = reshape(SO3F,sz(2:end));

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end