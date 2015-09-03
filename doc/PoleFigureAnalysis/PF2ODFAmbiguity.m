
cs = crystalSymmetry('222')

orix = orientation('axis',xvector,'angle',90*degree,cs)
oriy = orientation('axis',yvector,'angle',90*degree,cs)
oriz = orientation('axis',zvector,'angle',90*degree,cs)

odf1 = unimodalODF([orix,oriy,oriz])

ori = orientation('axis',vector3d(1,1,1),'angle',[0,120,240]*degree,cs)
odf2 = unimodalODF(ori)

%%

figure(1)
plotPDF(odf1,Miller({1,0,0},{0,1,0},{0,0,1},{1,1,1},...
  {1,1,0},{1,0,1},{0,1,1},{1,1,-1},cs),'contourf')
mtexColorMap LaboTeX
saveFigure('~/svn/potts-ag/paper/textureAnalysis/odf1_pf.png')

figure(2)
plotPDF(odf2,Miller({1,0,0},{0,1,0},{0,0,1},{1,1,1},...
  {1,1,0},{1,0,1},{0,1,1},{1,1,-1},cs),'contourf')

mtexColorMap LaboTeX

saveFigure('~/svn/potts-ag/paper/textureAnalysis/odf2_pf.png')

%%

figure(1)
plotPDF(odf1,Miller({1,1,0},cs))
figure(2)
plotPDF(odf2,Miller({1,1,0},cs))

%%

figure(1)
plot(odf1,'sections',6)
figure(2)
plot(odf2,'sections',6)

%%

psi = deLaValeePoussinKernel('halfwidth',30*degree);

A = psi.A;
A(2:end) = A(2:end) ./ 3;

psi = kernel(A);

A(2:2:end) = 0;


psi2 = kernel(A)


plot(psi)
hold all
plot(psi2)
hold off
ylim([0,22])
xlabel('misorientation angle from center')
ylabel('mrd')
saveFigure('~/svn/potts-ag/paper/textureAnalysis/evenOdd.png')

%%

cs = loadCIF('Fe-Iron-alpha')

Bain = orientation('map',Miller(0,0,1,cs),Miller(0,0,1,cs),Miller(0,1,1,cs),Miller(-1,1,0,cs))

% Pitch = 

