%% check Clebsch Gordan Tensor


%% the reference

% some arbitrary rotation
g = rotation.byEuler(-72*degree,-88*degree,-134*degree);

% we want to express the product of two wigner D functions
D1 = WignerD(g,'order',1);
D2 = WignerD(g,'order',2);
D1D2_ref = D1(:) * D2(:).'

%% expansion into Wigner functions of lower order

% zero order component
D0 = WignerD(g,'order',0);
CG0 = ClebschGordanTensor(1,2,0);
C0 = EinsteinSum(CG0,[1 3 -1],D0,[-1,-2],CG0,[2 4 -2])

% first order component
D1 = WignerD(g,'order',1);
CG1 = ClebschGordanTensor(1,2,1);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1,[2 4 -2])

% second order component
D2 = WignerD(g,'order',2);
CG2 = ClebschGordanTensor(1,2,2);
C2 = EinsteinSum(CG2,[1 3 -1],D2,[-1 -2],CG2,[2 4 -2])

% third order component
D3 = WignerD(g,'order',3);
CG3 = ClebschGordanTensor(1,2,3);
C3 = EinsteinSum(CG3,[1 3 -1],D3,[-1 -2],CG3,[2 4 -2])


a = reshape(matrix(C0 + C1 + C2 + C3),[9,25]) ./ D1D2_ref;

imagesc(real(a))
