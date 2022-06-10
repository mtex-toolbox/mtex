%% 1) exactnes of radon transform and different symmetries
% same problem for SO3FunHandle
RBF = SO3FunRBF.example;
SO3F = SO3FunHarmonic(RBF)

% inexact
rng('default')
r=rotation.rand(5);
RBF.eval(r)
SO3F.eval(r)

% inexact Radon transform
F1 = radon(RBF,xvector);
F2 = radon(SO3F,xvector);
v = vector3d.rand(5);
F1.eval(v)
F2.eval(v)

% but exact in case of simple symmetry '1'
RBF.CS = crystalSymmetry('1');
SO3F = SO3FunHarmonic(RBF);
F1 = radon(RBF,xvector);
F2 = radon(SO3F,xvector);
F1.eval(v)
F2.eval(v)


%% 3) Section-plot Error in pfSections when isa SRight 'specimenSymmetry'
% RH -> resolved for sigma
% this is a problem for functions created like
%SO3F = SO3FunHarmonic(rand(1e5,1));

SO3F = SO3FunHarmonic.example;
SO3F.CS = specimenSymmetry('1');
plot(SO3F,'sigma')
%plot(SO3F,'omega')
%plot(SO3F,'pf')

%% 4) Bug: all other Plots do not work anymore after trying 'ipf'
% RH: resolved

SO3F = SO3FunHarmonic.example;
plot(SO3F,'sigma')

plot(SO3F,'ipf')  % This yields an error message

plot(SO3F,'sigma')
%plot(SO3F)

%% 5) Error in eval by evaluating an SO3FunRBF with no proper Symmetry
% This problem is produced by convolution of SO3FunRBFs.
% example 1
rng(0)

F = inv(SO3FunRBF.example);

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


%% 6) Spherical Harmonics not L2-normalized
% We will not change this, but add an nice documentation about Wigner-D
% functions, Spherical Harmonics an the normalisation of SO3FunHarmonic and
% S2FunHarmonic

% We use normalized Wigner-D functions
SO3F2 = SO3FunHarmonic(1);
SO3F2.eval(rotation.rand(3))
mean(SO3F2)

% But not normalized Spherical Harmonics
sF1 = S2FunHarmonic(1);
sF1.eval(vector3d.rand(3))
mean(sF1)
sF2 = S2FunHandle(@(v) 1+0.*norm(v));


%% 7) Problems with Symmetries by convolution of SO3FunRBF and SO3FunRBF 
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

%% 8) KernelODF ist zu ungenau   --->  Damit ist calcError in der Doku häufig viel zu hoch
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
odf_rec = calcDensity(ori);

figure(2)
plot(odf_rec)

calcError(odf,odf_rec)


%% 9) Teste SO3Fun/calcMindex
% function hinzugefügt, aber es existiert kein Aufruf in der doku, also
% auch kein Test


%% 10) antipodal hat keine Auswirkung und wird nicht ermittelt
% 1) get.antipodal for general SO3Fun
% 2) set.antipodal for general SO3Fun
% 3) use antipodal in eval,...

cs = crystalSymmetry('1');
kappa = [20 0 10 30];
U = [zeros(3,1),(rotation.rand.matrix);1,zeros(1,3)];
f = BinghamODF(kappa,U,cs)
rng(0); 
r = rotation.rand(10);
f.eval(r)
f.eval(inv(r))

F1 = SO3FunHandle(@(rot) 0.5*(f.eval(rot)+f.eval(inv(rot))))
F1.antipodal = 1;
figure(1)
plot(F1)

f.antipodal = 1;
F2 = SO3FunHarmonic(f)
figure(2)
plot(F2)

%% 11) Zeitüberlauf in MinMax Methode

F = SO3FunHarmonic(1);
F.isReal = 1

max(F)

%% 12)  Fehler in

GrainOrientationParameters

%% 13) add load Function and correct import wizzard.       ODF ---> SO3Fun

ODFInport
VPSCInport




