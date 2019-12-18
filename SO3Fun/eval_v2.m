clear all

% create an test Function
SO3F=SO3FunHarmonic(ones(deg2dim(64),1));
tic
%% transform fhat to a matrix with dim (k,l) x n
N=SO3F.bandwidth;

fhat = zeros((2*N+1)^2,N+1);
a=zeros(2*N+1,2*N+1);
for n=0:N
    a((N+1)-n:(N+1)+n,(N+1)-n:(N+1)+n)=reshape(SO3F.fhat((deg2dim(n)+1):deg2dim(n+1)),2*n+1,2*n+1);
    fhat(:,n+1)=a(:);
end
toc
%% create Wigner d matrices: 
% d^{degree}_{k,l}(beta) is displayed by WignerD2(degree,0,beta,0)'(k,l) 
for n=0:N
    wig{n+1}=wignerD(n,0,pi/2,0)';
    wig{n+1}(isinf(wig{n+1}))=0;
    wig{n+1}(isnan(wig{n+1}))=0;
end
toc 

%% create FHAT with dim (k,l) x j rowwise
K=((2*N+1)^2-1)/2+1;


for j=0:2*N % paralellize over j leads to size(d) ~ N^4 which has to be saved
    d = zeros((2*N+1)^2,N+1); %matrix with dim (k,l) x n for fix j
    for n=N:-1:abs(j-N)
        w=zeros(2*N+1,2*N+1);
        w((N+1)-n:(N+1)+n,(N+1)-n:(N+1)+n) = wig{n+1};
        w1=w(:,j+1)*w(j+1,:);
        w1=w1';
        k=(numel(w1)-1)/2;
        d(K-k:K+k,n+1)=w1(:);
    end
    FHAT(:,j+1)=dot(fhat,d,2);
end
toc


FHAT=permute(reshape(FHAT,2*N+1,2*N+1,2*N+1),[2,3,1]);

FHAT=FHAT(1:end-1,1:end-1,1:end-1); %false, but we need size of even numbers

%% use NFFT
v=rotation.byEuler(25*degree,87*degree,34*degree);

vtilde=(Euler(v,'nfft')'+[pi/2;pi;pi/2])/(2*pi);

% initialize nfft plan
plan = nfftmex('init_3d',2*N,2*N,2*N,length(v));

% set rotations as nodes in plan
nfftmex('set_x',plan,vtilde);

% node-dependent precomputation
nfftmex('precompute_psi',plan);

% set Fourier coefficients
nfftmex('set_f_hat',plan,FHAT(:));

% fast fourier transform
nfftmex('trafo',plan);

% get function values from plan
f = real(nfftmex('get_f',plan))


eval(SO3F,v) 
% should it realy be 'nfft' in eval line 60, or better: Euler(v,'nfsoft') ???? 

