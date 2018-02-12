%% check S1Grid/find

x = S1Grid([1,2,3,4,9],0,10)
x = S1Grid([1,2,3,4,9,9.8],0,10,'periodic')

find(x,4,5)

x = S1Grid(0:39990,0,40000,'periodic');
y = linspace(0,39000,3000);

tic
for i = 1:100
  ind = find(x,y,50);
end
toc

tic
for i = 1:1
  for j = 1:length(y)
    find(x,y(j),50);
  end
end
toc


%% check S2Grid/find

x = equispacedS2Grid('points',500);
plot(subGrid(x,find(x,xvector,10*degree)));
full(find(x,xvector,10*degree))

x = equispacedS2Grid('points',5000);
y = vector3d(equispacedS2Grid('points',100));

tic
for i = 1:length(y)
  find(x,y(i),0.5);
end
toc

tic
for i = 1:100
  find(x,y,0.5);
end
toc

%% check SO3Grid/find

cs = crystalSymmetry('trigonal');
ss = specimenSymmetry('1');

x = equispacedSO3Grid(cs,ss,'points',100000);
y = equispacedSO3Grid(cs,ss,'points',100000);


tic
angle_outer(x,y,5*degree);
toc

tic
find(x,quaternion(y),5*degree);
toc

find(x,quaternion.id,20*degree)

q = axis2quat(xvector+yvector,45*degree);
q = quaternion.id;

sx = quaternion(subGrid(x,find(x,q,10*degree)));

dist(cs,specimenSymmetry,q,sx) / degree


plot(inv(sx)*xvector)
plot(inv(sx)*yvector)
plot(inv(sx)*zvector)


A = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

B = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

