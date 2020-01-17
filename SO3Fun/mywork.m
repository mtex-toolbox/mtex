clear all

SO3F=SO3FunHarmonic(rand(deg2dim(64),1));
N=SO3F.bandwidth;

%% evaluate at the grid

% fft: eval3fft
f1 = eval3fft(SO3F);

% nfft: eval2

%equidistant nodes for N
Grid(:,[3,2,1])=combvec(0:2*N,0:N,0:2*N)'*2*pi/(2*N+1); %(alpha,beta,gamma)
origrid=rotation.byEuler(Grid,'nfft');

f2 = eval2(SO3F,origrid);

% compare both
dist=ceil(log10(max(abs(f2(:)-f1(:)))));
disp(['nfft and fft differ at the grid by less than 10^',int2str(dist)])

%% evaluate at some rotations

ori = origrid(ceil(rand*((2*N+1)^2*(N+1)-5))+(1:5));

f3 = eval2(SO3F,ori);
f4 = eval4fft(SO3F,ori);

[f3, f4]

dist=ceil(log10(max(abs(f3(:)-f4(:)))));
disp(['nfft and fft differ at random rotations by less than 10^',int2str(dist)])
