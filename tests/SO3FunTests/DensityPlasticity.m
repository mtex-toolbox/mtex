%% Plasticity of DensityFunction on Sphere
clear

odf = SantaFe;
pdf = odf.calcPDF(Miller(1,0,0,odf.CS));
f = S2FunHarmonic(pdf)
mean(f)
mtexFig = newMtexFigure('layout',[2,2]);
plot(f)

phi = @(v) vector3d.byPolar((v.theta/pi).^1.3*pi,v.rho) ;

% a)
v = discreteSample(f,1e7);
v2 = phi(v);
f2 = calcDensity(v2,'kernel',S2DeLaValleePoussinKernel('halfwidth',5*degree));
nextAxis
plot(f2)

% b)
t = equispacedS2Grid('resolution',7.5*degree);
t2 = phi(t);
a = calcVoronoiArea(t); a = a(:);
b = calcVoronoiArea(t2); b = b(:);
max(a./b)
y = f.eval(t).*(a./b);
f3 = S2FunHarmonic.interpolate(t2,y);
nextAxis
plot(f3)



%% Plasticity of Density Function on Rotations

clear

f = SO3FunHarmonic(SantaFe); 
f.CS = crystalSymmetry; f.SS = specimenSymmetry; f.antipodal = false;
% mean(f)

phi = @(r) rotation.byEuler((Euler(r,'nfft')/2/pi).^[1,1,1.1]*2*pi);

% a)
v = discreteSample(f,5e6);
v2 = phi(v);
fa = calcDensity(v2,'kernel',SO3DeLaValleePoussinKernel('halfwidth',2.5*degree));
figure(1)
plot(fa)

% b)
t = equispacedSO3Grid(crystalSymmetry,'resolution',5*degree);
t = rotation(t(:));
t2 = phi(t);
y = f.eval(t);

% Versuch 1
a1 = calcVoronoiVolume(t);
b1 = calcVoronoiVolume(t2);

% Versuch 2
[V,C] = calcVoronoi(t);
for k=1:length(t)
  P = log(V(C{k}),t(k));
  [~,A] = convhulln(P.xyz);
  a2(k) = A;
  P2 = log(phi(V(C{k})),t2(k));
  [~,B] = convhulln(P2.xyz);
  b2(k) = B;
end

% [V,C] = calcVoronoi(t2);
% for k=1:length(t2)
%   P = log(V(C{k}),t2(k));
%   [~,A] = convhulln(P.xyz);
%   b(k) = A;
% end
a1 = a1(:); b1 = b1(:);
a2 = a2(:); b2 = b2(:);

y1 = y(:).*(a1./b1);
y2 = y(:).*(a2./b2);

fb1 = SO3FunHarmonic.interpolate(t2,y1,'bandwidth',35);
figure(2)
plot(fb1)
fb2 = SO3FunHarmonic.interpolate(t2,y2,'bandwidth',35);
figure(3)
plot(fb2)

save('densityPlasticitySO3.mat','fa','a1','b1','fb1','a2','b2','fb2')

%%
load('densityPlasticitySO3.mat')
max(a1./b1)
max(a2./b2)

figure(1)
plot(fa)
figure(2)
plot(fb1)
figure(3)
plot(fb2)
%%

plot(f)
