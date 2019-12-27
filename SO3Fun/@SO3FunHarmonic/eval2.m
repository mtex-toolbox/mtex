function f = eval2(SO3F,ori,varargin)

N = SO3F.bandwidth;

% precompute wigner d -> n x k x j
d = zeros(N+1,2*N+1,2*N+1);
for n = 0:N  
  d(n+1,N+1+(-n:n),N+1+(-n:n)) = wignerd(n,pi/2);  
end
%L = 3; int16(4^L*squeeze(d(L+1,:,:)).^2)

% bring f_hat in the form n x k x l
fhat = zeros(N+1,2*N+1,2*N+1);
for n = 0:N
  fhat(n+1,N+1+(-n:n),N+1+(-n:n)) = ...
    reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),1,2*n+1,2*n+1);
end

% ghat -> k x l x j
% we need to make it 2N+2 as the index set of the NFFT is -(N+2) ... N+1
ghat = zeros(2*N+2,2*N+2,2*N+2);

for j = -N:N
    
  dj = d(:,:,N+1+j);
  gj = fhat .* dj .* permute(dj,[1,3,2]);
    
  ghat(2:end,2:end,N+2+j) = sum(gj);
   
end

% NFFT
M = length(ori);

% alpha, beta, gamma
% this quite different from the paper I gave you - I do not why
abg = Euler(ori,'nfft')'./(2*pi);
abg = (abg + [-0.25;0;0.25]);
abg = [abg(2,:);abg(1,:);abg(3,:)];
abg = mod(abg,1);

% initialize nfft plan
%plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
NN = 2*N+2;
FN = ceil(1.5*NN);
plan = nfftmex('init_guru',{3,NN,NN,NN,M,FN,FN,FN,4,int8(0),int8(0)});

% set rotations as nodes in plan
nfftmex('set_x',plan,abg);

% node-dependent precomputation
nfftmex('precompute_psi',plan);

% set Fourier coefficients
nfftmex('set_f_hat',plan,ghat(:));

% fast fourier transform
nfftmex('trafo',plan);

% get function values from plan
f = nfftmex('get_f',plan);

end