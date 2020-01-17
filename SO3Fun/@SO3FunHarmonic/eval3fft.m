function f = eval3fft(SO3F,varargin)

N = SO3F.bandwidth;

% precompute wigner d -> n x k x j
d = zeros(N+1,2*N+1,2*N+1);
for n = 0:N  
  d(n+1,N+1+(-n:n),N+1+(-n:n)) = Wigner_D(n,pi/2);  
end
%L = 3; int16(4^L*squeeze(d(L+1,:,:)).^2)

% bring f_hat in the form n x k x l
fhat = zeros(N+1,2*N+1,2*N+1);
for n = 0:N
  fhat(n+1,N+1+(-n:n),N+1+(-n:n)) = ...
    reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),1,2*n+1,2*n+1);
end

% create ghat -> k x l x j
for j = -N:N
    
  dj = d(:,:,N+1+j);
  gj = fhat .* dj .* permute(dj,[1,3,2]);
    
  ghat(1:2*N+1,1:2*N+1,N+1+j) = sum(gj);
   
end
% correct ghat by exp(-2*pi*i*(-1/4*l+1/4*k))
z=zeros(2*N+1,2*N+1,2*N+1)+(0:2*N)'-(0:2*N);
ghat=ghat.*exp(-0.5*pi*i*z);

% transform ghat to l x j x k  
ghat=permute(ghat,[2,3,1]);

%create equidistant Grid (alpha,beta,gamma) c [0,2*pi)x[0,pi)x[0,2*pi)
G(:,[3,2,1])=combvec(0:2*N,0:2*N,0:2*N)'*2*pi/(2*N+1);
Grid=G(G(:,2)<pi,:);

%fft
f=permute(fftn(ghat),[3,2,1]);
f=f(G(:,2)<pi).*exp(i*N*sum(Grid,2));

end