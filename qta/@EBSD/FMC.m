function [criterion] = FMC(ebsd, A_D, cmaha, varargin)


fmc.CS = ebsd.CS{1};
fmc.O = quaternion(ebsd.rotations);

fmc.cmaha = cmaha;
fmc.cmaha0 = get_option(varargin,{'cmaha0'},0.05,'double');
fmc.quatmax = get_option(varargin,{'quatmax'},5,'double');
fmc.gammaW = get_option(varargin,{'gammaW'},25,'double');
fmc.alpha = get_option(varargin,{'alpha'},0.2,'double');
fmc.beta = get_option(varargin,{'beta'},0.3,'double');
fmc.A_D = A_D;

A_Dfull = A_D;


[AllPs,AllSals,numClusters] = FMC_MTEX(fmc);

assignments = FMC_interpret(AllSals, numClusters, AllPs, A_Dfull, fmc.beta);

[Dl, Dr] = find(A_Dfull);
criterion = assignments(Dl,1) == assignments(Dr,1);

% I_DG = sparse(1:length(assignments),assignments(:,1),1);
% I_DG(:,all(I_DG==0,1)) = [];

