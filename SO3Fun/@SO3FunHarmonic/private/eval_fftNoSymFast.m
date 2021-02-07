function f = eval_fftNoSymFast(SO3F,varargin)

N = SO3F.bandwidth;

% ghat -> k x l x j
ghat = zeros(2*N+1,2*N+1,2*N+1);

for n = 0:N

  Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

  d = Wigner_D(n,pi/2);
  D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

  ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:n)) = ...
      ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:n)) + D;

end

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