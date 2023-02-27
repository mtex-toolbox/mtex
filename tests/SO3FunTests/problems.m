%% 1) Error in eval by evaluating an SO3FunRBF with no proper Symmetry
% This problem is produced by convolution of SO3FunRBFs.
% example 1
rng(0)

F = inv(SO3FunRBF.example);
%F = inv(SO3FunHarmonic(SO3FunRBF.example))

H=F; H.SS = H.SS.properGroup
r=rotation.rand(5);
F.eval(r)
H.eval(r)

%%

% example 2
F=SO3FunRBF.example;
F.CS = crystalSymmetry;
F.SS = SO3Fun.dubna.CS
H=F; H.CS = H.SS.properGroup
F.eval(r)
H.eval(r)

% example 3
rng(0)
F1 = SO3FunRBF.example;
F1.CS = crystalSymmetry('2');
ori = orientation.rand(10,crystalSymmetry('1'),specimenSymmetry('2'));
F2 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',5*degree));

C3 = conv(F1,F2)
C4 = conv(SO3FunHarmonic(F1),F2)

C3.eval(r)
C4.eval(r)


%% Problems with Symmetries by convolution of SO3FunRBF and SO3FunRBF 
rng(0)
ori = orientation.rand(1,crystalSymmetry('2'),specimenSymmetry('2'));
F1 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',10*degree));
ori = orientation.rand(1,crystalSymmetry('432'),specimenSymmetry('2'));
F2 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',5*degree));

C3 = conv(F1,F2)
C4 = conv(SO3FunHarmonic(F1),F2)

figure(1)
plot(C3)
figure(2)
plot(C4)


%% 2) Problems with symmetries also by radon transform

rng(0)
o = orientation.rand(100,specimenSymmetry,SO3FunRBF.example.CS);
F = SO3FunRBF(o,SO3DeLaValleePoussinKernel)
A = radon(F,xvector);
B = radon(SO3FunHarmonic(F),xvector);
plot(A-B)






%% 3) KernelODF ist zu ungenau   --->  Damit ist calcError in der Doku häufig viel zu hoch
% verwendet in calcDensity, calcFourierODF
% Aber Achtung: calcDensity wird in
% problems/Missorientation/MissorientationDistributionFunction verwendet und
% dass funktioniert genau wie in der doku.

clear

odf = SO3FunRBF.example;
figure(1)
plot(odf)
ori = odf.discreteSample(50000);
hold on
plot(ori,'MarkerFaceColor','none','MarkerEdgeAlpha',0.5,'all','MarkerEdgeColor','k','MarkerSize',4)
hold off

odf_rec = calcKernelODF(ori);
%odf_rec = calcDensity(ori);

figure(2)
plot(odf_rec)

calcError(odf,odf_rec)


%% 4) Test SO3Fun/calcMindex
% function is added, but there exists no call in the doc. 
% Hence it is not tested yet.


%% 5) antipodal has no effect and is not determined in some subclasses of SO3Fun
% 1) get.antipodal for general SO3Fun
% 2) set.antipodal for general SO3Fun
% 3) use antipodal in eval,...

rng(3)
r = rotation.rand;
F = SO3FunBingham.example;  % erkennt nicht das bereits antipodal
%F = SO3FunCBF.example;      
%F = SO3FunHandle.example;
%F = SO3FunComposition.example;  % kann nicht antipodal setzen
F.CS = specimenSymmetry;
F.eval([r,r.inv])
F.antipodal = 1
F.eval([r,r.inv])

%% 7) add load Function and correct import wizzard.       ODF ---> SO3Fun

VPSCImport


%% 8) Halfwidth of SO3Kernel should get a new definition
% [See: test_KernelHalfwidth.m]
%
% i) The halfwidth of a kernel psi of a specific subclass of @SO3Kernel should be
% the same as the halfwidth of the correponding SO3Kernel which is produced
% by the chebychev coefficients of psi
% for example
psi = SO3DeLaValleePoussinKernel(100)
SO3Kernel(psi.A)

%
% ii) The halwidth should be the same for the gradient of an @SO3Kernel
psi.grad

%
% iii) Maybe set halfwidth for Kernels to pi. 
% Think about using the support instead.
% Here we have a problem in SO3FunRBF.K_symmetrised because it is cut off
% at 3.5*psi.halfwidth (look on epsilon)
cs = crystalSymmetry('-1');
alphaFibre = orientation.byAxisAngle(zvector,(-180:180)*degree,cs);

A = SO3Kernel(((-1).^(0:10)').*(1:2:21)');
psi = conv(SO3DeLaValleePoussinKernel(10),A);
odf1 = SO3FunRBF(orientation.id(cs),psi,1);
odf2 = FourierODF(odf1,10);


close all
plot(-180:180,odf1.eval(alphaFibre),'linewidth',2)
hold on
plot(-180:180,odf2.eval(alphaFibre),'linewidth',2)
hold off
legend('odf1','odf2')
xlim([-180,180])



%% RandomSampling
cs = crystalSymmetry('32');
fibre_odf = 0.5*uniformODF(cs) + 0.5*fibreODF(fibre.rand(cs),'halfwidth',20*degree);
ori = fibre_odf.discreteSample(50000)
odf_rec = calcDensity(ori)
calcError(odf_rec,fibre_odf)










