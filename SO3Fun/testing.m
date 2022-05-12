
mtexdata dubna
odf = calcODF(pf,'zero_range')
%%

FHarm = SO3FunHarmonic(odf.calcFourier,odf.CS,odf.SS)

plot(FHarm,'sigma')

%%

FRBF = SO3FunRBF(odf.components{1}.center,...
  SO3DeLaValleePoussinKernel(odf.components{1}.psi.kappa),...
  odf.components{1}.weights)

plot(FRBF,'sigma')

%%

plot(SO3FunHarmonic(FRBF),'sigma')

%%

cs1 = crystalSymmetry('321');
cs2 = crystalSymmetry('222');

odf2 = unimodalODF(orientation.copper(cs1));
odf1 = unimodalODF(orientation.copper2(cs2));
mdf1 = calcMDF(odf1,odf2,'kernelMethod')

mdf2 = calcMDF(odf1,odf2)
figure(1);plotSection(mdf1,'sigma')

figure(2);plotSection(mdf2,'sigma')

mori = mdf2.discreteSample(100);

hold on
cS = crystalShape.quartz;
plot(mori,0.1*(mori.project2FundamentalRegion*cS))
hold off

%%

psi = SO3DeLaValleePoussinKernel

plot(psi)

%%

phi = psi.radon
plot(phi)

%%

psi2 = SO3Kernel(psi.A)

plot(psi2)

%%

phi2 = psi2.radon
plot(phi2)

