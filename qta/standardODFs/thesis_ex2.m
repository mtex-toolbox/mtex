function [odf,h] = thesis_ex2(varargin)
% sample ODF 2 appearing in the thesis of Ralf Hielscher 2007

CS = symmetry('orthorhombic');
SS = symmetry('triclinic');

k1 = kernel('von Mieses Fischer',100,255);
q1 = quaternion(1,0,0,0);
odf(1) = 10/11 * ODF(q1,1,k1,CS,SS);

k2 = kernel('von Mieses Fischer',600,255);
q2 = axis2quat(xvector,10*degree);
odf(2) = 1/11*ODF(q2,1,k2,CS,SS);

h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)...
	,Miller(1,1,0),Miller(1,0,1),Miller(0,1,1),Miller(1,1,1)...
	];



