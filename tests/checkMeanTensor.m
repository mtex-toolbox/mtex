function checkMeanTensor


%% define a rank 1 tensor and rotate it

T = tensor([-1;0;1]);

o = rotation('Euler',150*degree,40*degree,35*degree);

%figure(1)
%rotate(T,o)
%plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',1*degree);

T_odf = calcTensor(odf,T,'Fourier');

%figure(2)
%plot(T_odf)

assert(norm(matrix(T_odf)-matrix(rotate(T,o)))<1e-3,'Error checking two rank tensor!')

%% define a rank 2 tensor and rotate it

T = tensor(diag([-1 0 1]));

o = rotation('Euler',150*degree,40*degree,35*degree);

%rotate(T,o)
%figure(1)
%plot(rotate(T,o))

%% do the same by an ODF

odf = unimodalODF(o,symmetry,symmetry,'halfwidth',1*degree);

T_odf = calcTensor(odf,T,'Fourier');

%figure(2)
%plot(T_odf)

assert(norm(matrix(T_odf)-matrix(rotate(T,o)))<1e-3,'Error checking two rank tensor!')
