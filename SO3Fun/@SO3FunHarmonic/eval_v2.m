function f = eval_v2(SO3F,rot,varargin)

persistent keepPlan;

% kill plan
if check_option(varargin,'killPlan')
  nfftmex('finalize',keepPlan);
  keepPlan = [];
  return
end

if isempty(rot), f = []; return; end


N = SO3F.bandwidth;

sz = size(rot);
rot = rot(:);
M = length(rot);

% alpha, beta, gamma
abg = Euler(rot,'nfft')'./(2*pi);
abg = (abg + [-0.25;0;0.25]);
abg = [abg(2,:);abg(1,:);abg(3,:)];
abg = mod(abg,1);

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlan;
else
  plan = [];
end

if isempty(plan)

  % initialize nfft plan
  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*N+2;
  N2 = N+1+mod(N+1,2);
  FN = ceil(1.5*NN);
  FN2 = ceil(1.5*N2);
  plan = nfftmex('init_guru',{3,NN,N2,NN,M,FN,FN2,FN,4,int8(0),int8(0)});

  % set rotations as nodes in plan
  nfftmex('set_x',plan,abg);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

f = zeros([length(rot) size(SO3F)]);
for k = 1:length(SO3F)

  % If SO3F is real valued we have the symmetry properties (*) and (**) for 
  % the Fourier coefficients. We will use this to speed up computation.
  if SO3F.isReal

    %ind = mod(N+1,2);
    % create ghat -> k x l x j
    %   k = -N+1:N
    %   l =    0:N+ind    -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
    %   j = -N+1:N        -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
    % we need to make it 2N+2 as the index set of the NFFT is -(N+1) ... N
    % we use ind in 2nd dimension to get even number of fourier coefficients
    % the additionally indices gives 0-columns in front of ghat
    % 2^0 -> fhat are the fourier coefficients of a real valued function
    % 2^1 -> make size of result even
    % 2^2 -> use L_2-normalized Wigner-D functions
    flags = 2^0+2^1+2^2;
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags);
  
  else

    % create ghat -> k x l x j
    % we need to make it 2N+2 as the index set of the NFFT is -(N+1) ... N
    % we can again use (**) to speed up
    % 2^1 -> make size of result even
    % 2^2 -> use L_2-normalized Wigner-D functions
    flags = 2^1+2^2;
    ghat = representationbased_coefficient_transform(N,SO3F.fhat(:,k),flags);
  
  end

  % set Fourier coefficients
  nfftmex('set_f_hat',plan,ghat(:));

  % fast fourier transform
  nfftmex('trafo',plan);

  % get function values from plan
  if SO3F.isReal
    % use (*) and shift summation in 2nd index
    f(:,k) = 2*real((exp(-2*pi*1i*ceil(N/2)*abg(2,:)')).*(nfftmex('get_f',plan)));
  else
    f(:,k) = nfftmex('get_f',plan);
  end
end


% kill plan
if check_option(varargin,'keepPlan')
  keepPlan = plan;
else
  nfftmex('finalize',plan);
end

if numel(SO3F) == 1, f = reshape(f,sz); end

end