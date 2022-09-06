%% 1) Error in eval by evaluating an SO3FunRBF with no proper Symmetry
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

%% 2) KernelODF ist zu ungenau   --->  Damit ist calcError in der Doku häufig viel zu hoch
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


%% 3) Teste SO3Fun/calcMindex
% function hinzugefügt, aber es existiert kein Aufruf in der doku, also
% auch kein Test


%% 4) antipodal hat keine Auswirkung und wird nicht ermittelt
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

%% 5)  Fehler in line 185 in

GrainOrientationParameters

%% 6) add load Function and correct import wizzard.       ODF ---> SO3Fun

ODFImport
VPSCImport

%% 7) setting symmetries for SO3FunHarmonic needs Befehl symmetrise
% oder?
rng(0)

F = SO3Fun.dubna;
F.CS = crystalSymmetry('422');
F.SS = specimenSymmetry('622');

F.eval(F.SS.rot*rotation.rand*F.CS.rot)

G = F.symmetrise;
G.eval(G.SS.rot*rotation.rand*G.CS.rot)


%% 8) test interpolation

G = SO3Fun.dubna;
ori = orientation.rand(1e5,G.CS,G.SS);
f = G.eval(ori);

F = SO3Fun.interpolate(ori,f)

max(abs([F.eval(ori),f]))

% A = SO3FunHarmonic.quadrature(ori,f,'bandwidth',64,'weights',1/deg2dim(64+1),'nfsoft')
% 
% [A.eval(ori),f]

%% 9) test approximation
clear 
rng(0)

G = SO3Fun.dubna;% G.CS=specimenSymmetry;
figure(1)
plot(G)
q = orientation.rand(1e5,G.CS);
% q = G.discreteSample(6e4);
f = G.eval(q);

F2 = SO3FunHarmonic.approximation(q,f,'tol',1e-6,'maxit',50,'bandwidth',25)
figure(2)
plot(F2)






