function check_equidistribution(cs,ss)

h = [Miller(1,0,0,cs),Miller(1,1,1,cs),Miller(1,1,0,cs)];

hh = symmetrise(h);

q = SO3Grid(5*degree,cs,ss);

k = kernel('de la Vallee Poussin','halfwidth',10*degree)

odf = ODF(q,ones(size(q))./numel(q),k,cs,ss)

plotpdf(odf,h,'resolution',5*degree)


return

cs = symmetry();
ss = symmetry();

res = 5*degree;

rotangle = res/2:res:pi-res/2;
points = numel(S2Grid('equispaced','resolution',res));

q = quaternion();
for i = 1:length(rotangle)
  rotax = S2Grid('equispaced','points',sin(rotangle(i)/2)^2*points);
  q = [q,axis2quat(vector3d(rotax),rotangle(i))];
end

q = SO3Grid(q,cs,ss);

k = kernel('de la Vallee Poussin','halfwidth',10*degree)

odf = ODF(q,ones(size(q))./numel(q),k,cs,ss)

plotpdf(odf,h,'resolution',5*degree)
