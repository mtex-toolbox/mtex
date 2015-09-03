

%% set symmetries

cs = crystalSymmetry('1');
h = [Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(0,0,1,cs),Miller(1,-3,-4,cs)];

%% check unimodal ODF

odf = unimodalODF(axis2quat(vector3d(2,-3,-5),60*degree),cs);
%odf = UnimodalODF(axis2quat(yvector,45*degree)*axis2quat(xvector,45*degree),cs);
fodf = calcFourier(odf,32);
fodf = FourierODF(fodf);

%fourier(fodf,'order',1)

%% plotPDF

figure(1);plotPDF(fodf,h)
figure(2);plotPDF(odf,h)

disp('check for equal pole figures!')
input('(return)')

%% plotIPDF

r = [xvector,yvector,vector3d(1,-3,5)];
figure(1);plotIPDF(fodf,r)
figure(2);plotIPDF(odf,r)

disp('check for equal pole figures!')
input('(return)')

%% plot ODF

figure(1);plot(fodf,'sections',6,'resolution',1*degree)
figure(2);plot(odf,'sections',6)

disp('check for equal ODFs!')
input('(return)')



%% check Fibre ODFs

odf = fibreODF(Miller(1,3,2,cs),vector3d(4,2,1),'halfwidth',20*degree)

%% compute Fourier coefficients
fodf = calcFourier(odf,32); 
fodf = FourierODF(fodf);

%fourier(fodf,'order',2)

%% plotPDF

figure(1);plotPDF(fodf,h)
figure(2);plotPDF(odf,h)

disp('check for equal pole figures!')
input('(return)')

%% plotIPDF

r = [xvector,yvector,vector3d(1,-3,5)];
figure(1);plotIPDF(fodf,r)
figure(2);plotIPDF(odf,r)

disp('check for equal pole figures!')
input('(return)')

%% plotODF

figure(1);plot(fodf,'sections',6)
figure(2);plot(odf,'sections',6)

disp('check for equal ODFs!')



