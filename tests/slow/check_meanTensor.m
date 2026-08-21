function check_meanTensor
% NB the figure()/plot() calls that used to sit between these sections were
% removed: every assertion here is on matrix(...) norms, so they added no
% coverage, and they opened figures 1 to 3 unguarded and never closed them -
% clobbering those figures in an interactive session and leaving them behind.


%% define a rank 1 tensor and rotate it

T = tensor([-1;0;1]);

o = rotation.byEuler(150*degree,40*degree,35*degree);

%figure(1)
%rotate(T,o)
%plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',1*degree);

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

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',1*degree);


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

%% do the same by an ODF

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',1*degree);


T_odf = calcTensor(odf,T,'Fourier');


assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<2e-3,'Error checking third rank tensor!')

%% do the same by an ODF with quadrature

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',2*degree);


T_odf_q = calcTensor(odf,T,'quadrature');


% compare the quadrature path against the Fourier path, not against rotate(T,o) -
% an ODF average of finite width differs from a delta function by more than the
% tolerance, and the quadrature grid resolves no more than about 2.5 degree
T_odf_f = calcTensor(odf,T,'Fourier');

assert(mean(abs(reshape(matrix(T_odf_q-T_odf_f),[],1)))<1e-3, ...
  'quadrature and Fourier disagree for the third rank tensor!')

%% define a rank 4 tensor and rotate it

M = zeros([3 3 3 3]);
M(1,1,1,1) = 1;
M(2,2,2,2) = 1;
M(3,3,3,3) = 1;
T = tensor(M);

%o = rotation.byEuler(150*degree,40*degree,35*degree);
o = rotation.byEuler(0*degree,50*degree,0*degree);

rotate(T,o)

%% do the same by an ODF


%psi = SO3Kernel([1 0 0 0 0]);

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',0.1*degree);
%odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),psi);



T_odf = calcTensor(odf,T,'Fourier')


assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')


%% compare with integration


%T_odf = calcTensor(odf,T)

%figure(3)
%plot(T_odf)

%assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')


% an unreachable scratch block was removed here 2026-07-28, see git history
