%% S2Kernels

rng('default')
psi = S2DeLaValleePoussinKernel(10);
%plot(psi)
figure(1)
F1 = S2FunHarmonic(psi);
plot(F1)

F2 = S2FunHandle( @(v) psi.eval(cos(angle(vector3d.Z,v))) );
figure(2)
plot(F2)

v=vector3d.rand
F1.eval(v)
F2.eval(v)

%% SO3 Kernels

rng(4)
psi = SO3DeLaValleePoussinKernel(4);
%plot(psi)
figure(1)
F1 = SO3FunHarmonic(psi);
plot(F1)

F2 = SO3FunHandle( @(rot) psi.eval(cos(angle(rot)/2)) );
figure(2)
plot(F2)

r = rotation.rand
F1.eval(r)
F2.eval(r)


%% convolution SO3Fun with SO3Fun
% Left sided (*L) and Right sided (*R) works

clear 
rng('default')

F1 = SO3FunHarmonic(rand(1e3,1),specimenSymmetry('1'),specimenSymmetry('222'))
F2 = SO3FunHarmonic(rand(1e2,1),crystalSymmetry('4'),specimenSymmetry('1'))
r = rotation.rand

% Left sided convolution
C=conv(F1,F2)
C.eval(r)
mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(inv(rot).*r)))

% calcMDF
F1 = SO3FunHarmonic(rand(1e3,1),crystalSymmetry('3'),specimenSymmetry('1'))
F1.fhat = conj(F1.fhat);
C = conv(inv(conj(F1)),F2)
C.eval(r)
cF1 = conj(F1);
mean(SO3FunHandle(@(rot) cF1.eval(rot).*F2.eval(rot.*r)))

% right sided convolution
F1 = SO3FunHarmonic(rand(1e3,1),crystalSymmetry('4'),specimenSymmetry('622'))
F2 = SO3FunHarmonic(rand(1e2,1),crystalSymmetry('622'),specimenSymmetry('3'))
C = conv(F1,F2,'Right');
C.eval(r)
mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(r.*inv(rot))))


%% convolution SO3Fun with S2Fun
% works
rng('default')
p = vector3d.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i,crystalSymmetry('432'),specimenSymmetry('222'));
%F1.isReal=1
F2 = S2FunHarmonicSym(rand(40^2,1)+1i*rand(40^2,1),specimenSymmetry('222'));

C = conv(F1,F2);
C.eval(p)

A = SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(rot.*p));
mean(A)

%% convolution SO3Fun with SO3Kernel & SO3Kernel with SO3Fun
% SO3F *L psi  ==  SO3F *R psi  ==  psi *R SO3F  ==  psi *L SO3F
% works
rng(1)
r = rotation.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i);%,crystalSymmetry('622'),specimenSymmetry('3'));
%F1.isReal=1
F2 = SO3DeLaValleePoussinKernel;

CL = conv(F1,F2); CL.eval(r)
CR = conv(F1,F2,'Right'); CR.eval(r)
CLi = conv(F2,F1); CLi.eval(r)
CRi = conv(F2,F1,'Right'); CRi.eval(r)

F2 = SO3FunHarmonic(F2);
C3 = conv(F1,F2); C3.eval(r)
C4 = conv(F1,F2,'Right'); C4.eval(r)
C5 = conv(F2,F1); C5.eval(r)
C6 = conv(F2,F1,'Right'); C6.eval(r)


%mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(inv(rot).*r)))
%mean(SO3FunHandle(@(rot) F2.eval(rot).*F1.eval(inv(rot).*r)))

%% convolution SO3Fun with S2Kernel
% works
rng(2)
p = vector3d.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i);%,crystalSymmetry('622'),specimenSymmetry('3'));
psi = S2DeLaValleePoussinKernel(10);

C1 = conv(F1,psi);
C1.eval(p)
figure(1)
plot(C1)

F2 = S2FunHarmonic(psi);
C2 = conv(F1,S2FunHarmonic(F2));
C2.eval(p)
figure(2)
plot(C2)

%% convolution SO3Kernel with SO3Kernel
% works
psi1 = SO3DeLaValleePoussinKernel(4);
psi2 = SO3GaussWeierstrassKernel;

C1 = SO3FunHarmonic(conv(psi1,psi2));
C2 = conv(SO3FunHarmonic(psi1),SO3FunHarmonic(psi2));


figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3Kernel with S2Kernel
% works
psi1 = SO3DeLaValleePoussinKernel(4);
psi2 = S2DeLaValleePoussinKernel(10);

C1 = S2FunHarmonic(conv(psi1,psi2));
C2 = conv(SO3FunHarmonic(psi1),S2FunHarmonic(psi2));

figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3Kernel with S2Fun
% works
psi = SO3DeLaValleePoussinKernel(4);
sF = S2Fun.smiley;

C1 = conv(psi,sF);
C2 = conv(SO3FunHarmonic(psi),sF);

figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3FunRBF with SO3Kernel
% works
F1 = SO3FunRBF.example;
psi = SO3DeLaValleePoussinKernel;

C1 = SO3FunHarmonic(conv(F1,psi))
C2 = conv(SO3FunHarmonic(F1),psi)

figure(1)
plot(C1)
figure(2)
plot(C2)
%% convolution SO3FunRBF with SO3FunRBF
% problems with symmetries
rng(0)
ori = orientation.rand(1,crystalSymmetry('2'),specimenSymmetry('2'));
F1 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',10*degree));
%F1 = SO3FunRBF.example;
%F1.CS = crystalSymmetry('2');
ori = orientation.rand(1,crystalSymmetry('432'),specimenSymmetry('2'));
F2 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',5*degree));

C3 = conv(F1,F2)
C4 = conv(SO3FunHarmonic(F1),F2)

r=rotation.rand(100);
r=r(65);
C3.eval(r)
C4.eval(r)

figure(1)
plot(C3)
figure(2)
plot(C4)

mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(inv(rot).*r)))


%% convolution S2Fun with S2Fun (meine Definition)

rng(3)
r=rotation.rand(1);

F1 = S2FunHarmonic(rand(2^2,1)+rand(2^2,1)*1i);
F2 = S2FunHarmonic(rand(2^2,1)+rand(2^2,1)*1i);

C = conv(F1,F2)
C.eval(r)

c2 = S2FunHandle(@(v) F1.eval(v).*F2.eval(r*v))
mean(c2.eval(equispacedS2Grid('resolution',0.5*degree)))


% bisherige Definition
% C3 = inv(4*pi*conv(F1,conj(F2)))
% C3.eval(r)
% 
% C4 = SO3FunHandle(@(rot) 4*pi*mean(S2FunHandle(@(v) F1.eval(v).*conj(F2.eval(rot.*v)))))
% C4.eval(r)



%% convolution S2Fun with S2Kernel (S2Kernel * S2Fun)

rng(0)
v=vector3d.rand(1);

F1 = S2FunHarmonic([1+5i,2+6i,3+7i,4+8i]');
F2 = S2Kernel([1+3i;2+4i]);

C = conv(F1,F2)
C.eval(v)

C2 = S2FunHandle(@(w) mean(S2FunHandle(@(v) F1.eval(v).*F2.eval(cos(angle(w,v)))    )))
C2.eval(v)

C.fhat/sqrt(4*pi)
C3 = conv(F1,S2FunHarmonic(F2))
C3.fhat

% S2Kernel * S2Fun
C4 = conv(S2FunHarmonic(F2),F1)
C4.fhat


%% convolution S2Kernel with S2Kernel

rng(0)
v=vector3d.rand(1);

F1 = S2Kernel([1+5i,2+6i,3+7i,4+8i]');
F2 = S2Kernel([1+3i;2+4i;5;2+1i]);

C1 = S2FunHarmonic(conv(F1,F2))
C2 = conv(S2FunHarmonic(F1),F2)
C3 = conv(S2FunHarmonic(F2),F1)

plot(C1)
figure
plot(C2)
figure
plot(C3)

