%% check Clebsch Gordan Tensor


%% the reference

% some arbitrary rotation
g = rotation.byEuler(-72*degree,88*degree,134*degree);

% we want to express the product of two wigner D functions
D1 = WignerD(g,'order',1);
D1D1_ref = D1(:) * D1(:).'

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


a = reshape(matrix(C0 + C1 + C2),[9,9]) ./ D;
A = round(a)

imagesc(A)

assert(norm(A.* D - reshape(matrix(C0 + C1 + C2),[9,9]))<=1e-10,'Clebsch Gordan check failed')
