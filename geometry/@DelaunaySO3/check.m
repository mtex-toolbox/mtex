function check
% ignore this

%%

cs = crystalSymmetry('-3m',[1.4 1.4 1.5])
ori = equispacedSO3Grid(cs,specimenSymmetry,'resolution',20*degree)
%ori = orientation.rand(100,cs);
%ori = orientation(rotation(crystalSymmetry('O')),cs)

% pertube data a bit
%odf_pertube = unimodalODF(idquaternion,'halfwidth',0.5*degree);
%ebsd = calcEBSD(odf_pertube,length(ori));
%ori = ebsd.rotations .* orientation(ori.subsref(':'));

DSO3 = DelaunaySO3(ori)
DSO3 = refine(DSO3);
%DSO3 = refine(DSO3);
%DSO3 = refine(DSO3);
%DSO3 = refine(DSO3);

%% check adjacence matrix
hist(sum(DSO3.A_tetra))


%% check neigbouring matrix

DSO3.tetraNeighbour(5,:)

DSO3.tetra([5,DSO3.tetraNeighbour(5,:)],:)

%% check find routine

%[ind,bario] = DSO3.findTetra(orientation.byEuler(10*degree,20*degree,5*degree,cs))

[ind,bario] = DSO3.findTetra(orientation.byEuler(317*degree,20*degree,0*degree,cs))

%%

odf = fibreODF(Miller(1,0,0,cs),zvector)

plotPDF(odf,Miller(1,0,0,cs))


%%

mtexdata dubna

odf = calcODF(pf,'zero_range')

%%

%dodf = odf;
%odf.c = ones(size(odf.c))./numel(odf.c);




%%

f = eval(odf,DSO3);

fodf = femODF(DSO3,'weights',f)

%%
tic
f = eval(odf,DSO3);
toc

tic
f = eval(fodf,DSO3);
toc

%%

plot(fodf,'sigma')

%%
%plot(fodf)
figure(1)
tic
plotPDF(odf,Miller(1,1,1,cs))
toc
figure(2)
tic
plotPDF(fodf,Miller(1,1,1,cs),'antipodal','pcolor')
toc

%%
f = fibre(Miller(1,1,1,cs),xvector);
tic
plot(fodf,f);
toc
hold all
tic
plot(odf,f);
toc
hold off

%% have there some to many adjecent tetrahegons?
[m,ind] = max(sum(DSO3.A_tetra))

% show them
tetra = find(DSO3.A_tetra(ind,:))

% show vertices
[u,v] = find(DSO3.I_oriTetra(tetra,:))

DSO3(unique(v))

angle_outer(DSO3(unique(v)),DSO3(unique(v))) / degree

tic

q = SO3Grid(1000000);

d = squeeze(double(q));

[K, v] = convhulln(d);

toc

%

cs = crystalSymmetry('m-3m');


for k = 1:numel(cs)


  q1 = cs(k)*q;

end

%% define an

cs = crystalSymmetry('O');

x = linspace(-pi,pi,56);
y = linspace(-pi,pi,56);
z = linspace(-pi,pi,56);

[x,y,z] = meshgrid(x,y,z);

v = vector3d(x,y,z);
v = v(norm(v)<pi);

%%

ori = orientation.byAxisAngle(v,norm(v),cs)

%%
oR = fundamentalRegion(ori.CS,ori.SS);
ind = oR.checkInside(ori);

%%

plot(quaternion(ori(ind)),'scatter')

%%

max(angle(quaternion(ori(ind)))) / degree

%%

h = Miller(1,0,0,cs)
r = regularS2Grid('antipodal')

M = pdfMatrix(DSO3,h,r);

%%

cs = crystalSymmetry('-3m',[1.4 1.4 1.5])
ori = equispacedSO3Grid(cs,specimenSymmetry,'resolution',5*degree)
DSO3 = DelaunaySO3(ori)

%%

odf = unimodalODF(orientation.byEuler(10*degree,0,0,cs),'halfwidth',20*degree)

%%

h = {Miller(1,1,1,cs),Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(1,2,1,cs)};

pf = odf.calcPoleFigure(h,regularS2Grid('resolution',5*degree))

fodf = calcFEMODF(pf,DSO3)

%%

plotPDF(fodf,h)

%%

plot(fodf,'sigma')
