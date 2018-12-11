function checkMeanTensor


%% define a rank 1 tensor and rotate it

T = tensor([-1;0;1]);

o = rotation.byEuler(150*degree,40*degree,35*degree);

%figure(1)
%rotate(T,o)
%plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',1*degree);

T_odf_f = calcTensor(odf,T,'Fourier');
T_odf_q = calcTensor(odf,T,'quadrature');

%figure(2)
%plot(T_odf)

assert(norm(matrix(T_odf_f)-matrix(rotate(T,o)))<1e-3,'Error checking one rank tensor!')

%% define a rank 2 tensor and rotate it

T = tensor(diag([-1 0 1]));

o = rotation.byEuler(150*degree,40*degree,35*degree);

%rotate(T,o)
%figure(1)
%plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',1*degree);


T_odf = calcTensor(odf,T,'Fourier');

%figure(2)
%plot(T_odf)

assert(norm(matrix(T_odf)-matrix(rotate(T,o)))<1e-3,'Error checking two rank tensor!')

%% define a rank 3 tensor and rotate it

Md =[[-2.30   2.30    0      0.67    0        0  ];...
  [     0      0    0       0    -0.67     4.60];...
  [     0      0    0       0      0        0 ]];

T = tensor(Md);

o = rotation.byEuler(150*degree,40*degree,35*degree);

%rotate(T,o)
figure(1)
plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',1*degree);


T_odf = calcTensor(odf,T,'Fourier');

figure(2)
plot(T_odf)

assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<2e-3,'Error checking third rank tensor!')

%% do the same by an ODF with quadrature

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',2*degree);


T_odf_q = calcTensor(odf,T,'quadrature');

figure(3)
plot(T_odf_q)

assert(mean(abs(reshape(matrix(T_odf_q-rotate(T,o)),[],1)))<2e-3,'Error checking third rank tensor!')

%% define a rank 4 tensor and rotate it

M = zeros([3 3 3 3]);
M(1,1,1,1) = 1;
M(2,2,2,2) = 1;
M(3,3,3,3) = 1;
T = tensor(M);

%o = rotation.byEuler(150*degree,40*degree,35*degree);
o = rotation.byEuler(0*degree,50*degree,0*degree);

rotate(T,o)
figure(1)
plot(rotate(T,o))

%% do the same by an ODF


%psi = kernel('Fourier',[1 0 0 0 0]);

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',0.1*degree);
%odf = unimodalODF(o,symmetry,symmetry,psi);



T_odf = calcTensor(odf,T,'Fourier')

figure(2)
plot(T_odf)

assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')


%% compare with integration


%T_odf = calcTensor(odf,T)

%figure(3)
%plot(T_odf)

%assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')

%%

%%

s = 2.5;
N = 10^7;
Lo = 0:100;
kappa = 5;
A = (2*Lo+1) .* kappa.^2 ./ (kappa.^2 +  (2*Lo+1).^2 .* Lo.^(s+0.5) .* (Lo+1).^(s+0.5) ./N);
psi = kernel('Fourier',A);

odf = calcODF(ebsd_corrected,C_Epidote,'kernel',psi,'phase',2)

[C_Voigt, C_Reuss, C_Hill] =  calcTensor(odf_Epidote,C_Epidote)

%%

S3G = orientation('random',CS{1},SS,'points',10)

psi = kernel('di',4)

%odf = unimodalODF(S3G,CS{1},SS,psi)
odf = calcODF(S3G,'kernel',psi)

calcTensor(S3G,C_Glaucophane)
calcTensor(odf,C_Glaucophane)
