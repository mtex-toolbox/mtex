
%% one dimensional example

cs = symmetry;
T = tensor([1;0;0],cs);
plot(T)

%%

[F,T_hat] = Fourier(T);

%D = wignerD(idquaternion,'order',1);

EinsteinSum(T_hat,[1 -1 -2],wignerD(rotation('Euler', 50*degree,0*degree, 0),'order',1),[-1 -2])

%%

D = wignerD(rotation('Euler', 90*degree,60*degree, 45*degree),'order',1);

T_hat = rotate(T,U);
T_hat = EinsteinSum(T,-1,U,[-1 1]);
T_hat = EinsteinSum(T_hat,2,U',[3 1]);

EinsteinSum(T,-1,U,[-1 -2],D,[-2 -3],U',[-3 1])

EinsteinSum(T_hat,[1 -1 -2],D,[-1,-2])

%% check Clebsch Gordan Tensor

g = rotation('Euler',-72*degree,88*degree,134*degree);

D1 = wignerD(g,'order',1) 
D = D1(:) * D1(:).';

%g = rotation('Euler',72*degree,38*degree,34*degree);

D0 = wignerD(g,'order',0);
CG0 = ClebschGordanTensor(0);
C0 = D0*EinsteinSum(CG0,[1 3],CG0,[2 4])

D1 = wignerD(g,'order',1);
CG1 = ClebschGordanTensor(1);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1,[2 4 -2])

D2 = wignerD(g,'order',2);
CG = ClebschGordanTensor(2);
C2 = EinsteinSum(CG,[1 3 -1],D2,[-1 -2],CG,[2 4 -2])

%matrix(C0 + C1 + C2)

mypcolor(abs(reshape(matrix(C0 + C1 + C2),[9,9])-D.*A))
colorbar

a = reshape(matrix(C0 + C1 + C2),[9,9]) ./ D;
A = round(a)

%% a two dimensional example

cs = symmetry;
T = tensor(diag([1,0,0]),cs);
plot(T)

% a rotation
g = rotation('Euler',72*degree,38*degree,34*degree);

% reference tensor
T_rot = rotate(T,g)

% transform into Wigner D
U = tensorU;
D = wignerD(g,'order',1);
%EinsteinSum(U,[1 -2],D,[-2 -3],U',[-3 2])
%matrix(g)

T1 = EinsteinSum(T,[-1 -2],U',[1 -1],U',[2 -2]);
DD = EinsteinSum(tensor(D),[1 2],D,[3 4]);


% replace DD by 

D0 = wignerD(g,'order',0);
D1 = wignerD(g,'order',1);
D2 = wignerD(g,'order',2);


CG0 = ClebschGordanTensor(0);
C0 = D0*EinsteinSum(CG0,[1 3],CG0,[2 4]);

CG1 = ClebschGordanTensor(1);
C1 = EinsteinSum(CG1,[1 3 -1],D1,[-1 -2],CG1,[2 4 -2]);

CG = ClebschGordanTensor(2);
C2 = EinsteinSum(CG,[1 3 -1],D2,[-1 -2],CG,[2 4 -2]);

DD2 = (C0 + C1 + C2) .* tensor(reshape(A,[3 3 3 3]));

% sum further

T2 = EinsteinSum(T1,[-1 -2],DD2,[1 -1 2 -2]);
T3 = EinsteinSum(T2,[-1 -2],U,[1 -1],U,[2 -2]);

%%

% order 0 Fourier coefficient

CG0 = ClebschGordanTensor(0);
C0 = EinsteinSum(CG0,[1 3],CG0,[2 4]);
DD0 = C0 .* tensor(reshape(A,[3 3 3 3]));

T2 = EinsteinSum(T1,[-1 -2],DD0,[1 -1 2 -2]);
C0hat = EinsteinSum(T2,[-1 -2],U,[1 -1],U,[2 -2])

% order 1 Fourier coefficient
 
CG1 = ClebschGordanTensor(1);
C1 = EinsteinSum(CG1,[1 3 5],CG1,[2 4 6]);

DD1 = C1 .* tensor(reshape(A,[3 3 3 3]));

T2 = EinsteinSum(T1,[-1 -2],DD1,[1 -1 2 -2 3 4]);
C0hat = EinsteinSum(T2,[-1 -2 3 4],U,[1 -1],U,[2 -2])





%%

[F,T_hat] = Fourier(T);

%D = wignerD(idquaternion,'order',1);

D = wignerD(rotation('Euler', 0*degree,0*degree, 0),'order',2);
3*EinsteinSum(T_hat,[1 2 -1 -2],D,[-1 -2])












%% define an ODF

odf1 = unimodalODF(rotation('Euler',45*degree,0,0));
odf2 = unimodalODF(rotation('Euler',90*degree,90*degree,90*degree));

T_odf = calcTensor(0.5*(odf2 + odf1),T,'Fourier');

plot(T_odf)



%%

odf = 1;



% numerical integration
S3G = SO3Grid(10*degree,symmetry,symmetry);

f2 = matrix(S3G);

g = Euler(S3G,'nfft');
c = f2(2,2,:)/numel(S3G);
L = 1;
A = [1 1 1 1];

% run NFSOFT
D = call_extern('odf2fc','EXTERN',g,c,A);
      
% extract result
D = 3*complex(D(1:2:end),D(2:2:end));

D(1)
M*reshape(D(2:10),3,3)*M^-1

%%

M = [[i/sqrt(2) 0 i/sqrt(2)];[-1/sqrt(2) 0 1/sqrt(2)];[0 i 0]]

r = rotation('axis',yvector+xvector+zvector,'angle',20*degree); matrix(r),M*wignerD(r,'degree',1)*M.'
