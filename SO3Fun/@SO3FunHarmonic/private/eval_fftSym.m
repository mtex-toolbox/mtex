function f = eval_fftSym(SO3F,varargin)

N = SO3F.bandwidth;

% if SO3F is real valued we have (*) and (**) for the Fourier coefficients
% we will use this to speed up computation

% create ghat -> k x l x j
% with  k = -N:N
%       l =  0:N        -> use ghat(-k,-l,-j) = conj(ghat(k,l,j))      (*)
%       j = -N:N        -> use ghat(k,l,-j) = (-1)^(k+l)*ghat(k,l,j)   (**)
ghat = zeros(2*N+1,N+1,2*N+1);

for n = 0:N

  Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
  Fhat = Fhat(:,n+1:end);

  d = Wigner_D(n,pi/2); d = d(:,1:n+1);
  D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

  ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) = ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) +D;

end
% use (**)
pm = (-1)^(N+1)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;

% needed for (*)
ghat(:,1,:) = ghat(:,1,:)/2;

% correct ghat by exp(-2*pi*i*(-1/4*l+1/4*k))
z = zeros(2*N+1,N+1,2*N+1)+(-N:N)'-(0:N);
ghat = ghat.*exp(-0.5*pi*1i*z);

% fft
f = fftn(ghat,[2*N+1,2*N+1,2*N+1]);

f = f(:,:,1:N+1);                      % because beta is only in [0,pi]
z = (0:2*N)'+reshape(0:N,1,1,N+1);     % needed to shift summation for fft
                                       % from [-N:N] to [0:2N]
f = 2*real(exp(2i*pi*z*N/(2*N+1)).*f); % shift summation & use (*)
f = permute(f,[1,3,2]);

end