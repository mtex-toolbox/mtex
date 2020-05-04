function f = eval2v3(SO3F,ori,varargin)

tic
N = SO3F.bandwidth;

% ghat -> k x l x j
% we need to make it 2N+2 as the index set of the NFFT is -(N+2) ... N+1
ghat=zeros(2*N+2,2*N+2,2*N+2);

if SO3F.isReal
% if SO3F is real valued the Fourier coefficients are symmetric with
% respect to j, we can use this to speed up computation

  for n=0:N

    Fhat=reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;
  
    ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) = ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) + D;
  end
  pm = -reshape((-1).^(1:(2*N+1)^2),[2*N+1,2*N+1]);
  ghat(2:end,2:end,N+2+(1:N)) = flip(ghat(2:end,2:end,N+2+(-N:-1)),3) .* pm;
  
  % actually we should also have ghat(k,l,j) = conj(ghat(k,l,j))
  % lets check this
  
  % ghat(2:end,2:end,2:end) = conj(flip(flip(flip(ghat(2:end,2:end,2:end),1),2),3));
  
  % this seems to work an allows us to reduce computational time again by
  % factor 2
  
  
else
  for n=0:N

    Fhat=reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d=Wigner_D(n,pi/2);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

    ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:n)) = ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:n)) + D;
  end
end
toc
tic
% NFFT
M = length(ori);

% alpha, beta, gamma
% this quite different from the paper I gave you - I do not know why
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
toc
end
