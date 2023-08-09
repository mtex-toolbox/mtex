function [SO3F1,SO3F2,SO3F3] = example(varargin)

% In this example we consider Olivine with has orthorhombic symmetry
csOli = crystalSymmetry('222',[4.779 10.277 5.995],'mineral','olivine');

% and the basic slip systems in olivine
sSOli = slipSystem(Miller({1,0,0},{1,0,0},{0,0,1},csOli,'uvw'),...
  Miller({0,1,0},{0,0,1},{0,1,0},csOli,'hkl'));

% a given macroscopic strain tensor
E = strainRateTensor([1 0 0; 0 0 0; 0 0 -1]);

% The solutions of the continuity equation can be analytically computed and
% are available via the command <SO3FunSBF.SO3FunSBF.html |SO3FunSBF|>.
% This command takes as input the specific slips system |sS| and the
% makroscopic strain tensor |E|
SO3F1 = SO3FunSBF(sSOli(1),E);
SO3F2 = SO3FunSBF(sSOli(2),E);
SO3F3 = SO3FunSBF(sSOli(3),E);



end

