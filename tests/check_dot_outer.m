cs = crystalSymmetry('m-3m')
ss = specimenSymmetry('mmm')
g0 = Miller2quat(Miller(1,2,2,cs),Miller(2,2,1,cs));

%%
x = eval(SantaFe,...
  SO3Grid(1.25*degree,cs,ss));
sum(x)/length(x)

%%
x = eval(unimodalODF(g0,cs,ss,'halfwidth',5*degree),...
  SO3Grid(2.5*degree,cs,ss));
sum(x)/length(x)

%%
x = eval(unimodalODF(axis2quat(xvector,0*degree),cs,ss,'halfwidth',5*degree),...
  SO3Grid(1.25*degree,cs,ss));
sum(x)/length(x)

%%
x = eval(unimodalODF(axis2quat(xvector,45*degree),cs,ss,'halfwidth',15*degree),...
  SO3Grid(1.25*degree,cs,ss));
sum(x)/length(x)
%%
cs = crystalSymmetry('m-3m')
ss = specimenSymmetry('mmm')
omega = linspace(0,pi/2,20);
for i = 1:length(omega)
  odf = unimodalODF(axis2quat(xvector,omega(i)),cs,ss,'halfwidth',5*degree);
  x = eval(odf,SO3Grid(0.75*degree,cs,ss));
  v(i) = sum(x)/length(x);
  fprintf('.');
end
fprintf('\n');
plot(omega,v);

%%
ss = specimenSymmetry('mmm');
cs = crystalSymmetry('4/mmm');
q = axis2quat(vector3d(1,1,1),2*pi/3*(0:2));
q= q(1);
g = SO3Grid(10*degree,cs,ss);
e = 90*degree;
qq = quaternion(g);
q0 = axis2quat(yvector,30*degree);
q0 = rotation.byEuler(70*degree,45*degree,80*degree);
q1 = rotation.byEuler(0*degree,0*degree,0*degree);
%%

dd = dot_outer(g,...
  q0*q,'epsilon',e,...
  'nocubictrifoldaxis');

sum(dd > cos(e/2))


%%
dd = dot_outer(g,...
  q1*q,'epsilon',e,...
  'nocubictrifoldaxis');
sum(dd > cos(e/2))

%%
i = find(d > cos(e/2));

gi = subGrid(g,i)
qi = quaternion(gi);
imagesc(acos(full(dot_outer(gi,gi,'nocubictrifoldaxis'))));
%%

d = dot_outer(g,...
  q0*q,'full');

sum(d > cos(e/2))

%%
d = dot_outer(g,...
  q1*q,'full');
sum(d > cos(e/2))

%%
i = find(dd > cos(e/2));
plot(i,acos(d(i))*2,'.')
plot(i,acos(dd(i))*2,'.','color','r')
hold on
plot(1:10,e)
plot(acos(d)*2)
%%
x = histcounts(acos(d)/degree*2,0:5:100);
plot(cumsum(x))
hold on


%%

cs = crystalSymmetry('211');

S3G = equispacedSO3Grid(cs,symmetry,'points',3000);

q = quaternion.rand(1000);

epsilon = 180*degree;
tic, d1 = dot_outer(S3G,q,'epsilon',epsilon);toc

tic, d2 = dot_outer(S3G,q,'full');toc

disp(['Error: ' num2str(max(abs(d1(:)-d2(:)))), ...
  '  Expected Error: ' num2str(cos(epsilon/2))])


%%

imagesc(d1-d2)
