function f = eval_SymNFFTDecompose(SO3F,ori,varargin)

N = SO3F.bandwidth;

% if SO3F is real valued we have (*) and (**) for the Fourier coefficients,
% we can use this to speed up computation

% create ghat -> k x l x j
% with  k = -N:N
%       l =  0:N        -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
%       j =  1:N        -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
ghat = zeros(2*N+1,N+1,N+1);

for n = 0:N

  Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
  Fhat = Fhat(:,n+1:end);

  d = Wigner_D(n,pi/2); d = d(:,n+1:end);
  D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

  ghat(N+1+(-n:n),1:n+1,1:n+1) = ghat(N+1+(-n:n),1:n+1,1:n+1) + D;

end

% needed for (*)
ghat(:,1,:) = ghat(:,1,:)/2;

% NFFT
M = length(ori);

% alpha, beta, gamma
abg = Euler(ori,'nfft')'./(2*pi);
abg = (abg + [-0.25;0;0.25]);
abg = [abg(2,:);abg(1,:);abg(3,:)];
abg = mod(abg,1);

ind = mod(N+1,2);
ind2 = mod(N,4)<2;
ind3 = mod((N+1-ind)/2,2);

for i = 0:4

% divide 3-Tensor ghat(k,l,j) in 4 parts and compute NFFT for everyone
% We need sum for k+l=even and sum for k+l=odd separately
% sometimes there are 0-rows or columns added, because the index set of
% the NFFT is needed even: -(N+2) ... N+1

  switch i
    case 0
      G = zeros(2*N+2,N+1+ind);
      G(2:end,1+ind:end) = ghat(:,:,1);
      ABG = abg(2:3,:);
      fac = exp(-2*pi*1i*ceil(N/2)*ABG(1,:));

    case 1
      % needed for (**) / do NFFT for (a,b,g) and (a,b,-g)
      abg = [abg,abg];
      abg(1,M+1:2*M) = -abg(1,M+1:2*M);

      % ABG for NFFT, because we bisect the bandwiths k,l
      ABG = abg; ABG(3,:) = 2*ABG(3,:); ABG(2,:) = 2*ABG(2,:);

      % 1.) k odd, l odd
      G = zeros(N+(1-ind),(N+1-ind)/2+ind3,N+(1-ind));
      G(:,1+ind3:end,2-ind:end) = ghat(1+ind:2:end,2:2:end,2:end);
      fac = exp(-2*pi*1i*(abg(3,:)));
      fac = fac.*exp(-2*pi*1i*(floor((N+1)/4)*2+1)*abg(2,:));

    case 3
      % 2.) k odd, l even
      G = zeros(N+(1-ind),(N+1+ind)/2+ind2,N+(1-ind));
      G(:,1+ind2:end,2-ind:end) = ghat(1+ind:2:end,1:2:end,2:end);
      fac = exp(-2*pi*1i*abg(3,:));
      fac = fac.*exp(-2*pi*1i*abg(2,:)*((N+1+ind)/2-ind2));

    case 4
      % 3.) k even, l odd
      G = zeros(N+ind+1,(N+1-ind)/2+ind3,N+(1-ind));
      G(2:end,1+ind3:end,2-ind:end) = ghat(2-ind:2:end,2:2:end,2:end);
      fac = exp(-2*pi*1i*(floor((N+1)/4)*2+1)*abg(2,:));

    case 2
      % 4.) k even, l even
      G = zeros(N+ind+1,(N+1+ind)/2+ind2,N+(1-ind));
      G(2:end,1+ind2:end,2-ind:end) = ghat(2-ind:2:end,1:2:end,2:end);
      fac = exp(-2*pi*1i*abg(2,:)*((N+1+ind)/2-ind2));
  end

  % shift of j=1:N -> j=-N/2:N/2-1
  if i>0
    fac = fac.*exp(-2*pi*1i*abg(1,:)*(N+1+ind)/2);
  end
  
  % initialize nfft plan
  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  N1 = size(G,1);
  N2 = size(G,2);
  FN1 = ceil(1.5*N1);
  FN2 = ceil(1.5*N2);
  if i==0
    plan = nfftmex('init_guru',{2,N2,N1,M,FN2,FN1,4,int8(0),int8(0)});
  else
    N3 = size(G,3);
    FN3 = ceil(1.5*N3);
    plan = nfftmex('init_guru',{3,N3,N2,N1,2*M,FN3,FN2,FN1,4,int8(0),...
        int8(0)});
  end

  % set rotations as nodes in plan
  nfftmex('set_x',plan,ABG);

  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

  % set Fourier coefficients
  nfftmex('set_f_hat',plan,G(:));

  % fast fourier transform
  nfftmex('trafo',plan);

  % get function values from plan
  val = conj(nfftmex('get_f',plan)');

  % multiply with fac, which gives shift of k,l,j
  switch i
    case 0
      jzer = real(fac.*val);
    case 1
      f1 = real(fac.*val);
    case 2
      f1 = f1 + real(fac.*val);   % sum for k+l=even
    case 3
      f2 = real(fac.*val);
    case 4
      f2 = f2 + real(fac.*val);   % sum for k+l=odd
  end

end

f = 2*(jzer' + f1(1:M)' + f2(1:M)' + f1(M+1:end)' - f2(M+1:end)');

end