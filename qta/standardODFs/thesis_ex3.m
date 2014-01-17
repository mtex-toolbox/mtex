function [odf,h] = thesis_ex3(varargin)
% sample ODF 3 appearing in the thesis of Ralf Hielscher 2007

CS = symmetry('trigonal');
SS = symmetry('triclinic');

k = kernel('fibre von Mieses Fischer',100,255);

odf = ODF({Miller(0,0,1),zvector},1,k,CS,SS,'FIBRE');

h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)...
	,Miller(1,1,0),Miller(1,0,1),Miller(0,1,1),Miller(1,1,1)...
	];
