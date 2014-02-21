function [odf,h] = thesis_ex1(varargin)
% sample ODF 1 appearing in the thesis of Ralf Hielscher 2007

CS = symmetry('orthorhombic');
SS = symmetry('triclinic');

q1 = quaternion(1,0,0,0);
k1 = kernel('Abel Poisson',0.85,127);
odf(1) = 5/6 * ODF(q1,1,k1,CS,SS);

q2 = axis2quat(zvector,25*degree);
k2 = kernel('Abel Poisson',0.92,127);
odf(2) = 1/6 * ODF(q2,1,k2,CS,SS);

h = [Miller(0,0,1),Miller(0,1,0),Miller(0,1,1)...
	,Miller(1,0,0),Miller(1,0,1),Miller(1,1,0),Miller(1,1,1)...
	];

return

% simple test

% pf = PoleFigure(orig,h,S2Grid(50));
% rec = CWaveODF(pf,'ODF_TEST',orig)

omega = linspace(-pi,pi,50);
gx = axis2quat(xvector,omega);
gy = axis2quat(yvector,omega);
gz = axis2quat(zvector,omega);
dx = eval(orig,gx);
dy = eval(orig,gy);
dz = eval(orig,gz);
plot(omega,[dx,dy,dz]);
xlim([omega(1),omega(end)]);

omega = linspace(-pi,pi,150);
gx = axis2quat(xvector+yvector+zvector,omega);
gy = axis2quat(yvector+zvector-xvector,omega);
gz = axis2quat(zvector+xvector-yvector,omega);
dx = eval(rec,gx);
dy = eval(rec,gy);
dz = eval(rec,gz);
plot(omega,[dx,dy,dz,eval(orig,gx),ones(size(dx))]);
xlim([omega(1),omega(end)]);
