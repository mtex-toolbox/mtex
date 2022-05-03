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

%% 2) first is not antipodal, second is
RBF = SO3FunRBF.example;
SO3F = SO3FunHarmonic(RBF)

%% 3) Section-plot Error in pfSections when isa SRight 'specimenSymmetry'
% this is a problem for functions created like 
%SO3F = SO3FunHarmonic(rand(1e5,1));

SO3F = SO3FunHarmonic.example;
SO3F.CS = specimenSymmetry('1');
plot(SO3F,'sigma')
%plot(SO3F,'omega')
%plot(SO3F,'pf')

%% 4) Bug: all other Plots do not work anymore after trying 'ipf'
SO3F = SO3FunHarmonic.example;
plot(SO3F,'sigma')

plot(SO3F,'ipf')  % This yields an error message

plot(SO3F,'sigma')
%plot(SO3F)

%% 5) Error in halfwidth of SO3DirichletKernel
% change K to A in this code-line isnot enough
psi = SO3DirichletKernel(20)

%% 6) The kernels are defined for real numbers. 
% I think that is correct, because we insert angle(rot) or something
% else as argument. We should add an doc for this or should think about 
% change to argument rotation instead!!!

psi = SO3deLaValleePoussin(10);
%SO3DirichletKernel(20);
plot(psi)
psi.eval(rand)

%% 7) Error in eval by evaluating an SO3FunRBF with no proper Symmetry
% This problem is produced by convolution of SO3FunRBFs.
% example 1
rng(0)
F = inv(SO3FunRBF.example);
H=F; H.SS = H.SS.properGroup
r=rotation.rand(5);
F.eval(r)
H.eval(r)

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
F2 = SO3FunRBF(ori,SO3deLaValleePoussin('halfwidth',5*degree));

C3 = conv(F1,F2)
C4 = conv(SO3FunHarmonic(F1),F2)

C3.eval(r)
C4.eval(r)


%% 8) Spherical Harmonics not L2-normalized

% We use normalized Wigner-D functions
SO3F2 = SO3FunHarmonic(1);
SO3F2.eval(rotation.rand(3))
mean(SO3F2)

% But not normalized Spherical Harmonics
sF1 = S2FunHarmonic(1);
sF1.eval(vector3d.rand(3))
mean(sF1)
sF2 = S2FunHandle(@(v) 1+0.*norm(v));


