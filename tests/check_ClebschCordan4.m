%% check Clebsch Gordan Tensor


%% the reference

% some arbitrary rotation
g = rotation.byEuler(-72*degree,-88*degree,-134*degree);

% we want to express the product of two wigner D functions
D2 = WignerD(g,'order',2);
D1D2_ref = D2(:) * D2(:).';

%% expansion into Wigner functions of lower order

% zero order component
D0 = WignerD(g,'order',0);
CG0 = ClebschGordanTensor(2,2,0);
C0 = EinsteinSum(CG0,[1 3 -1],D0,[-1,-2],CG0,[2 4 -2])

% first order component
D1 = WignerD(g,'order',1);
CG1 = ClebschGordanTensor(2,2,1);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1,[2 4 -2])

% second order component
D2 = WignerD(g,'order',2);
CG2 = ClebschGordanTensor(2,2,2);
C2 = EinsteinSum(CG2,[1 3 -1],D2,[-1 -2],CG2,[2 4 -2])

% third order component
D3 = WignerD(g,'order',3);
CG3 = ClebschGordanTensor(2,2,3);
C3 = EinsteinSum(CG3,[1 3 -1],D3,[-1 -2],CG3,[2 4 -2])

% fourth order component
D4 = WignerD(g,'order',4);
CG4 = ClebschGordanTensor(2,2,4);
C4 = EinsteinSum(CG4,[1 3 -1],D4,[-1 -2],CG4,[2 4 -2])


a = reshape(matrix(C0 + C1 + C2 + C3 + C4),[25,25]) ./ D1D2_ref;

imagesc(real(a))
mtexColorMap white2black

%% next we expand D1 * D1 * D1 * D1 in the same way

%% the reference

% some arbitrary rotation
g = rotation.byEuler(-72*degree,-88*degree,-134*degree);

% we want to express the product of four wigner D functions
D1 = WignerD(g,'order',1);

T2D1_ref = D1(:) * D1(:).';
T4D1_ref = T2D1_ref(:) * T2D1_ref(:).';

%% expansion into Wigner functions of lower order

%% zero order component

T4D1 = tensor(zeros(repmat(3,1,8)));
for J = 0:4

  DJ = WignerD(g,'order',J);

  CGJ = tensor(zeros([repmat(3,1,8),2*J+1,2*J+1]),'rank',10);
  for j1 = 0:2
    for j2 = 0:2
      CGj1 = ClebschGordanTensor(1,1,j1);
      CGj2 = ClebschGordanTensor(1,1,j2);
      CGj1j2J = ClebschGordanTensor(j1,j2,J);
      C = EinsteinSum(...
        CGj1,[1 3 -1],...
        CGj1,[2 4 -2],...
        CGj2,[5 7 -3],...
        CGj2,[6 8 -4],...
        CGj1j2J,[-1 -3 9],...
        CGj1j2J,[-2 -4 10]);
      CGJ = CGJ + C;
    end
  end
  T4D1 = T4D1 + EinsteinSum(CGJ,[1:8 -1 -2],DJ,[-1 -2])

end

%%

a = reshape(double(T4D1),[3*3*3*3,3*3*3*3]) ./ T4D1_ref;

imagesc(real(a))
