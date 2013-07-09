function [criterion] = FMC(ebsd, A_D, cmaha, Dl, Dr, varargin)

cmaha0 = get_option(varargin,{'cmaha0'},0.05,'double');
quatmax = get_option(varargin,{'quatmax'},5,'double');
gammaW = get_option(varargin,{'gammaW'},25,'double');
alpha = get_option(varargin,{'alpha'},0.2,'double');
beta = get_option(varargin,{'beta'},0.3,'double');

A_Dfull = A_D;

FMC_MTEX

assignments = FMC_interpret(AllSals, numClusters, AllPs, A_Dfull, beta);

[Dl, Dr] = find(A_Dfull);
criterion = assignments(Dl,1) == assignments(Dr,1);

% I_DG = sparse(1:length(assignments),assignments(:,1),1);
% I_DG(:,all(I_DG==0,1)) = [];

