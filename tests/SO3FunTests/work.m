
cs = crystalSymmetry('432');

% define a family of slip systems
sS = slipSystem.bcc(cs);

% 30 percent plaine strain
q = 0;
epsilon = 0.1 * strainTensor(diag([1 -q -(1-q)]));

tic
[taylorF,~,spin] = calcTaylor(epsilon,sS.symmetrise,'bandwidth',24);
toc

%% method 1 - density estimation with very many orientations for reference

N = 1000000;

ori = orientation.rand(N,sS.CS);

numIter = 10;

progress(0,numIter);
for sas=1:numIter

  % compute the Taylor factors and the orientation gradients
  W = spinTensor(inv(ori) .* spin.eval(ori)) / numIter;

  % rotate the individual orientations
  ori = ori .* orientation(-W);
  progress(sas,numIter);

end

%%

odf0 = calcDensity(ori,'halfwidth',2.5*degree)

plotPDF(odf0,Miller({0,0,1},{1,1,1},cs))

%% method 2 - density with 

ori0 = equispacedSO3Grid(cs,'resolution',2.5*degree)

[V,C] = calcVoronoi(ori0,'struct');
w0 = calcVoronoiVolume(ori0,V,C);
%y0 = odf.eval(ori0);
y0 = 1;

%%

ori = ori0;

numIter = 20;

progress(0,numIter);
for sas=1:numIter

  % compute the Taylor factors and the orientation gradients
  W = spinTensor(inv(ori) .* spin.eval(ori)) / numIter;

  % rotate the individual orientations
  ori = ori .* orientation(-W);
  progress(sas,numIter);

end

%%

w1 = calcVoronoiVolume(ori);
y1 = y0 .* (w0 ./ w1);

odf1 = SO3FunHarmonic.approximation(ori(:),y1(:))


figure(2)
plotPDF(odf1,Miller({0,0,1},{1,1,1},cs))





%% ----------------------------------------------------------------

[f1,~,s1] = calcTaylor(inv(ori)*epsilon,sS.symmetrise);
%ori.symmetrise .* reshape(vector3d(s1),[],1)

ori * vector3d(s1)

[f,~,s] = calcTaylor(epsilon,sS.symmetrise,'bandwidth',32)

s.eval(ori)


%%

% plot the Taylor factor
plotSection(taylorF,'phi1',(0:10:90)*degree)
mtexColorbar

hold on
plot(spin,'color','k','resolution',10*degree)
hold off

%% Texture evolution during rolling

% define some random orientations
rng(0)
ori0 = equispacedSO3Grid(cs,'resolution',2.5*degree);
ori = ori0;
% 30 percent plane strain
q = 0;
epsilon = 0.3 * strainTensor(diag([1 -q -(1-q)]));



%%

odf = calcDensity(ori);


plotPDF(odf,Miller({0,0,1},{1,1,1},cs))

%%

ori0 = equispacedSO3Grid(cs,'resolution',5*degree)

[V,C] = calcVoronoi(ori0,'struct');
w0 = calcVoronoiVolume(ori0,V,C);
%y0 = odf.eval(ori0);
y0 = 1;

%%

ori = ori0;

numIter = 20;

progress(0,numIter);
for sas=1:numIter

  % compute the Taylor factors and the orientation gradients
  W = spinTensor(inv(ori) .* spin.eval(ori)) / numIter;

  % rotate the individual orientations
  ori = ori .* orientation(-W);
  progress(sas,numIter);

end

%%
figure(1)
w1 = calcVoronoiVolume(ori);
y1 = y0 .* (w0 ./ w1);

odf1 = SO3FunHarmonic.approximation(ori(:),y1(:))


plotPDF(odf1,Miller({0,0,1},{1,1,1},cs))

%%

w2 = calcVoronoiVolume(ori,V,C);
y2 = y0 .* (w0 ./ w2);

odf2 = SO3FunHarmonic.approximation(ori(:),y2(:))

%%




%%
figure(3)
odf3 = calcDensity(ori,'halfwidth',5*degree)
plotPDF(odf3,Miller({0,0,1},{1,1,1},cs))

%%



plotPDF(odf,Miller({0,0,1},{1,1,1},cs))

%%

ori = regularSO3Grid(cs,'resolution',5*degree)

%ori = odf.discreteSample(10000)

v = max(0,odf.eval(ori) + 0.2*randn(size(ori)));

odf1 = SO3FunHarmonic.approximation(ori,v,'bandwidth',32)
odf2 = SO3FunHarmonic.approximation(ori,v,'constantWeights','bandwidth',32)

%%

norm(odf1-odf)
norm(odf2-odf)

%%
figure(1)
plot(odf1)
figure(2)
plot(odf2)

%%







