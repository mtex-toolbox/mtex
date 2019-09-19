function check_equidistribution(cs,ss)

h = [Miller(1,0,0,cs),Miller(1,1,1,cs),Miller(1,1,0,cs)];

hh = symmetrise(h);

q = SO3Grid(5*degree,cs,ss);

k = deLaValleePoussinKernel('halfwidth',10*degree)

odf = unimodalODF(q,k,cs,ss)

plotPDF(odf,h,'resolution',5*degree)


return

cs = crystalSymmetry();
ss = specimenSymmetry();

res = 5*degree;

rotangle = res/2:res:pi-res/2;
points = length(equispacedS2Grid('resolution',res));

q = quaternion();
for i = 1:length(rotangle)
  rotax = equispacedS2Grid('points',sin(rotangle(i)/2)^2*points);
  q = [q,axis2quat(vector3d(rotax),rotangle(i))];
end

q = SO3Grid(q,cs,ss);

k = deLaValleePoussinKernel('halfwidth',10*degree)

odf = unimodalODF(q,k,cs,ss)

plotPDF(odf,h,'resolution',5*degree)
