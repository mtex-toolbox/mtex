

%% set symmetries

cs = symmetry('-1');
ss = symmetry('-1');  
h = [Miller(1,0,0),Miller(1,1,0),Miller(0,0,1),Miller(1,-3,-4)];

%% check unimodal ODF

odf = unimodalODF(axis2quat(vector3d(2,-3,-5),60*degree),cs,ss);
%odf = UnimodalODF(axis2quat(yvector,45*degree)*axis2quat(xvector,45*degree),cs,ss);
fodf = calcFourier(odf,32);
fodf = FourierODF(fodf);

%fourier(fodf,'order',1)

%% plotpdf

figure(1);plotpdf(fodf,h)
figure(2);plotpdf(odf,h)

disp('check for equal pole figures!')
input('(return)')

%% plotodf

figure(1);plot(fodf,'sections',6)
figure(2);plot(odf,'sections',6)

disp('check for equal ODFs!')
input('(return)')



%% check Fibre ODFs

odf = fibreODF(Miller(1,3,2),vector3d(4,2,1),cs,ss,'halfwidth',20*degree)

%% compute Fourier coefficients
fodf = calcFourier(odf,32); 
fodf = FourierODF(fodf);

%fourier(fodf,'order',2)

%% plotpdf

figure(1);plotpdf(fodf,h)
figure(2);plotpdf(odf,h)

disp('check for equal pole figures!')
input('(return)')

%% plotodf

figure(1);plot(fodf,'sections',6)
figure(2);plot(odf,'sections',6)

disp('check for equal ODFs!')



