function f = eval2(SO3F,rot,varargin)

N = SO3F.bandwidth;

% If SO3F is real valued we have the symmetry properties (*) and (**) for 
% the Fourier coefficients. We will use this to speed up computation.
if SO3F.isReal

  ind = mod(N+1,2);

  % create ghat -> k x l x j
  %   k = -N+1:N
  %   l =    0:N+ind    -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
  %   j = -N+1:N        -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
  % we need to make it 2N+2 as the index set of the NFFT is -(N+1) ... N
  % we use ind in 2nd dimension to get even number of fourier coefficients
  % the additionally indices gives 0-columns in front of ghat
  ghat = zeros(2*N+2,N+1+ind,2*N+2);

  for n = 0:N

    Fhat = reshape(SO3F.fhat(deg2dim(n)+1+n*(2*n+1):deg2dim(n+1)),2*n+1,n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

    ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) + D;

  end

  % use (**) by last index
  pm = (-1)^(ind)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
  ghat(2:end,1+ind:end,N+2+(1:N)) = ...
      flip(ghat(2:end,1+ind:end,N+2+(-N:-1)),3) .* pm;

  % use (*) by 2nd index
  ghat(:,1+ind,:) = ghat(:,1+ind,:)/2;

else

  % create ghat -> k x l x j
  % we need to make it 2N+2 as the index set of the NFFT is -(N+1) ... N
  % we can again use (**) to speed up
  ghat = zeros(2*N+2,2*N+2,2*N+2);

  for n = 0:N

    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

    ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) + D;

  end
  
  % use (**) by last index
  pm = -reshape((-1).^(1:(2*N+1)*(2*N+1)),[2*N+1,2*N+1]);
  ghat(2:end,2:end,N+2+(1:N)) = ...
      flip(ghat(2:end,2:end,N+2+(-N:-1)),3) .* pm;

end


% nfft
sz = size(rot);
rot = rot(:);
M = length(rot);

% alpha, beta, gamma
abg = Euler(rot,'nfft')'./(2*pi);
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
if SO3F.isReal
  % use (*) and shift summation in 2nd index
  f = 2*real((exp(-2*pi*1i*ceil(N/2)*abg(2,:)')).*(nfftmex('get_f',plan)));
else
  f = nfftmex('get_f',plan);
end

f = reshape(f,sz);

end