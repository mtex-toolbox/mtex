%% check Clebsch Gordan Tensor


%% the reference

% some arbitrary rotation
g = rotation.byEuler(-72*degree,88*degree,134*degree);

% the rotation matrix
R = matrix(g);

% we want to express the product of two of those rotation matrice

RR_ref = R(:) * R(:).'



%% Express R by D

D1 = WignerD(g,'order',1);
D = D1(:) * D1(:).';

EinsteinSum(U,[1 -1],D1,[-1 -2],conj(U),[2 -2])


%% expansion into Wigner functions of lower order

% zero order component
D0 = WignerD(g,'order',0);
CG0 = ClebschGordanTensor(0);
C0 = D0*EinsteinSum(CG0,[1 3],CG0,[2 4])

% first order component
D1 = WignerD(g,'order',1);
CG1 = ClebschGordanTensor(1);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1,[2 4 -2])

% second order component
D2 = WignerD(g,'order',2);
CG2 = ClebschGordanTensor(2);
C2 = EinsteinSum(CG2,[1 3 -1],D2,[-1 -2],CG2,[2 4 -2])

C = EinsteinSum(C0 + C1 + C2,[-1 -2 -3 -4],U,[1 -1],conj(U),[2 -2],U,[3 -3],conj(U),[4 -4]);
real(reshape(matrix(C),[9 9]))

assert(norm(D - reshape(matrix(C0 + C1 + C2),[9,9]))<=1e-10,'Clebsch Gordan check failed')


%%


% zero order component
D0 = WignerD(g,'order',0);
CG0 = EinsteinSum(ClebschGordanTensor(0),[-1 -2],U,[1 -1],U,[2 -2]);
CG0c = EinsteinSum(ClebschGordanTensor(0),[-1 -2],conj(U),[1 -1],conj(U),[2 -2]);
C0 = D0*EinsteinSum(CG0,[1 3],CG0c,[2 4])

% first order component
D1 = WignerD(g,'order',1);
CG1 = EinsteinSum(ClebschGordanTensor(1),[-1 -2 3],U,[1 -1],U,[2 -2]);
CG1c = EinsteinSum(ClebschGordanTensor(1),[-1 -2 3],conj(U),[1 -1],conj(U),[2 -2]);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1c,[2 4 -2])

% second order component
D2 = WignerD(g,'order',2);
CG2 = EinsteinSum(ClebschGordanTensor(2),[-1 -2 3],U,[1 -1],U,[2 -2]);
CG2c = EinsteinSum(ClebschGordanTensor(2),[-1 -2 3],conj(U),[1 -1],conj(U),[2 -2]);
C2 = EinsteinSum(CG2,[1 3 -1],D2,[-1 -2],CG2c,[2 4 -2])

C = C0 + C1 + C2;
TT_ref ./ real(reshape(matrix(C),[9 9]))

assert(norm(TT_ref - reshape(matrix(C),[9,9]))<=1e-10,'Clebsch Gordan check failed')
