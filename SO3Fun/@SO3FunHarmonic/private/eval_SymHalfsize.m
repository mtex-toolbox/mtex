function f = eval_SymHalfsize(SO3F,ori,varargin)

N = SO3F.bandwidth;

ind = mod(N+1,2);

% create ghat -> k x l x j
% we need to make it 2N+2 as the index set of the NFFT is -(N+1) ... N
ghat = zeros(2*N+2,N+1+ind,2*N+2);

% if SO3F is real valued the Fourier coefficients are symmetric with
% respect to j, we can use this to speed up computation

for n = 0:N

  Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
  Fhat = Fhat(:,n+1:end);

  d = Wigner_D(n,pi/2); d = d(:,1:n+1);
  D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

  ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) = ...
      ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) + D;

end

% we use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)
pm = (-1)^(ind)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
ghat(2:end,1+ind:end,N+2+(1:N)) = ...
    flip(ghat(2:end,1+ind:end,N+2+(-N:-1)),3) .* pm;

% actually we also have ghat(k,l,j) = conj(ghat(-k,-l,-j)) and use it by
% 2nd index: l=0-ind : N --> ind is the number of 0-columns in front
ghat(:,1+ind,:) = ghat(:,1+ind,:)/2;


% nfft
M = length(ori);

% alpha, beta, gamma
abg = Euler(ori,'nfft')'./(2*pi);
abg = (abg + [-0.25;0;0.25]);
abg = [abg(2,:);abg(1,:);abg(3,:)];
abg = mod(abg,1);

% initialize nfft plan
%plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
NN = 2*N+2;
N2 = size(ghat,2);
FN = ceil(1.5*NN);
FN2 = ceil(1.5*N2);
plan = nfftmex('init_guru',{3,NN,N2,NN,M,FN,FN2,FN,4,int8(0),int8(0)});

% set rotations as nodes in plan
nfftmex('set_x',plan,abg);

% node-dependent precomputation
nfftmex('precompute_psi',plan);

% set Fourier coefficients
nfftmex('set_f_hat',plan,ghat(:));

% fast fourier transform
nfftmex('trafo',plan);

% get function values from plan
% use symmetry property and shift summation in 2nd index to -N/2-1 : N/2
f = 2*real((exp(-2*pi*1i*ceil(N/2)*abg(2,:)')).*(nfftmex('get_f',plan)));

end