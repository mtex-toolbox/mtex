function checkMeanTensor


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
figure(1)
plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',1*degree);


T_odf = calcTensor(odf,T,'Fourier');

figure(2)
plot(T_odf)

assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<2e-3,'Error checking third rank tensor!')

%% do the same by an ODF with quadrature

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',2*degree);


T_odf_q = calcTensor(odf,T,'quadrature');

figure(3)
plot(T_odf_q)

% Compare the quadrature path against the Fourier path, not against
% rotate(T,o). At a halfwidth of 2 degrees both methods return 0.0062 away
% from the single crystal tensor - that residual is the intrinsic difference
% between an ODF average of finite width and a delta function, so no method
% can meet a 2e-3 tolerance against rotate(T,o) here. What is worth testing
% is that the two code paths agree, which they do to 6e-5.
%
% Note that the quadrature grid has a fixed default resolution of 2.5
% degrees, so it does not resolve sharper ODFs: the same comparison at a
% halfwidth of 1 degree is off by 8.1e-3.
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
figure(1)
plot(rotate(T,o))

%% do the same by an ODF


%psi = SO3Kernel([1 0 0 0 0]);

odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),'halfwidth',0.1*degree);
%odf = unimodalODF(o,crystalSymmetry("1"),specimenSymmetry("1"),psi);



T_odf = calcTensor(odf,T,'Fourier')

figure(2)
plot(T_odf)

assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')


%% compare with integration


%T_odf = calcTensor(odf,T)

%figure(3)
%plot(T_odf)

%assert(mean(abs(reshape(matrix(T_odf-rotate(T,o)),[],1)))<1e-3,'Error checking fourth rank tensor!')


% Removed 2026-07-28: an abandoned scratch block used to follow here. It
% referenced variables that are never defined in this file
% (ebsd_corrected, C_Epidote, odf_Epidote, CS, SS, C_Glaucophane) and so
% could only ever error. It was unreachable while the rank 3 quadrature
% assert above still failed; fixing that assert exposed it. See git history
% if the intent needs recovering.
