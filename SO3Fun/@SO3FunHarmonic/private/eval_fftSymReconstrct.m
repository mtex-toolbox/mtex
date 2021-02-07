function f = eval_fftSymReconstrct(SO3F,varargin)

N = SO3F.bandwidth;

% ghat -> k x l x j
ghat = zeros(2*N+1,2*N+1,2*N+1);

% if SO3F is real valued the Fourier coefficients are symmetric with
% respect to j, we can use this to speed up computation

for n=0:N

  Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
  Fhat = Fhat(:,1:n+1);

  d = Wigner_D(n,pi/2); d = d(:,1:n+1);
  D = permute(d,[1,3,2]) .* permute(d(1:n+1,:),[3,1,2]) .* Fhat;

  ghat(N+1+(-n:n),N+1+(-n:0),N+1+(-n:0)) = ...
      ghat(N+1+(-n:n),N+1+(-n:0),N+1+(-n:0)) + D;

end

pm = -reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
ghat(:,1:N+1,N+1+(1:N)) = flip(ghat(:,1:N+1,N+1+(-N:-1)),3) .*pm;

% actually we also have ghat(k,l,j) = conj(ghat(-k,-l,-j))
ghat(:,N+1+(1:N),:) =  ...
    conj(flip(flip(flip(ghat(:,N+1+(-N:-1),:),1),2),3));


% correct ghat by exp(-2*pi*i*(-1/4*l+1/4*k))
z = zeros(2*N+1,2*N+1,2*N+1)+(0:2*N)'-(0:2*N);
ghat = ghat.*exp(-0.5*pi*1i*z);

% transform ghat to l x j x k
ghat = permute(ghat,[2,3,1]);

% create equidistant Grid (alpha,beta,gamma) c [0,2*pi)x[0,pi)x[0,2*pi)
G(:,[3,2,1]) = combvec(0:2*N,0:2*N,0:2*N)'*2*pi/(2*N+1);
Grid = G(G(:,2)<pi,:);

% fft
f = permute(fftn(ghat),[3,2,1]);
f = f(G(:,2)<pi).*exp(1i*N*sum(Grid,2));

end