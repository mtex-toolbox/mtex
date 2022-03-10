%% test quadrature

N=64
% S={'1','112','3','4','6','2','222','32','422','622','23','432','312'};
CS=crystalSymmetry('622');
SS=specimenSymmetry('32');
fhat = 2*rand(deg2dim(N+1),1)+2*rand(deg2dim(N+1),1)*1i-1-1i;
F = SO3FunHarmonic(fhat,CS,SS);
%F.antipodal=1;
%F.isReal=1;
F

tic
Q = SO3FunHarmonic.quadrature(F,'bandwidth',N);
toc
tic
Q2 = SO3FunHarmonic.quadrature_v2(F,'bandwidth',N);
toc

F-Q
F-Q2

%% test eval with symmetry

N=64
% S={'1','112','3','4','6','2','222','32','422','622','23','432','312'};
CS=crystalSymmetry('1');
SS=specimenSymmetry('1');
fhat = 2*rand(deg2dim(N+1),1)+2*rand(deg2dim(N+1),1)*1i-1-1i;
F = SO3FunHarmonic(fhat,CS,SS);
f = @(v) F.eval(v);


tic
% Use crystal and specimen symmetries by only evaluating in fundamental
% region. Therefore adjust the bandwidth to crystal and specimen symmetry.
t1=1; t2=2; 
if CS.multiplicityPerpZ==1 || SS.multiplicityPerpZ==1, t2=1; end
if SS.id==22,  t2=4; end     % 2 | (N+1)
if CS.id==22, t1=4; end     % 2 | (N+1)
while (mod(2*N+2,CS.multiplicityZ*t1) ~= 0 || mod(2*N+2,SS.multiplicityZ*t2) ~= 0)
  N = N+1;
end

% evaluate function handle f at Clenshaw Curtis quadrature grid by
% using crystal and specimen symmetry
[values,nodes,W] = eval_onCCGrid_useSym(f,N,CS,SS);
toc

tic
% ignore symmetry by using 'complete'
[nodes,W] = quadratureSO3Grid(2*N,'ClenshawCurtis',CS,SS,'complete');
values = f(nodes(:));
toc





%% test adjoint_representationbased wigner transform with symmetry

%mex -R2018a adjoint_representationbased_coefficient_transform.c
%mex -R2018a adjoint_representationbased_coefficient_transform_old.c
N=64
% S={'1','112','3','4','6','2','222','32','422','622','23','432','312'};
CS=crystalSymmetry('1');
SS=specimenSymmetry('1');
fhat = 2*rand(deg2dim(N+1),1)+2*rand(deg2dim(N+1),1)*1i-1-1i;
F = SO3FunHarmonic(fhat,CS,SS);
%F.antipodal=1;
%F.isReal=1;
F

ghat = rand(2*N+1,2*N+1,2*N+1);
flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
if F.isReal
  flags = flags+2^2;
end
if F.antipodal
  flags = flags+2^3;
end
sym = [min(CS.multiplicityPerpZ,2),CS.multiplicityZ,min(SS.multiplicityPerpZ,2),SS.multiplicityZ];

tic
fhat= adjoint_representationbased_coefficient_transform(N,ghat,flags,sym);
fhat = symmetrise_fouriercoefficients_aRBWT(fhat,flags,sym);
toc
tic
fhat2 = adjoint_representationbased_coefficient_transform_old(N,ghat,flags);
toc


