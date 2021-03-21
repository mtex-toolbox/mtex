function [criterion] = gbc_FMC(q, CS, Dl,Dr, cmaha, varargin)
%
%  cmaha      - 
%  cmaha0     - lower misorientation bias (default 0.05)
%  quatmax    - quaterion variance metrix for cluster (default 5)
%  alpha      - seed selection (default 0.2)
%  beta       - probability threshold for point in cluster (default 0.3)%
%  gammaW     - edge dilution (default 25)

A_D = sparse(Dl,Dr,true,length(q),length(q));

fmc.CS = CS;
fmc.O  = q;

fmc.cmaha    = cmaha(1);
fmc.cmaha0   = get_option(varargin,{'cmaha0'},0.05,'double');
fmc.quatmax  = get_option(varargin,{'quatmax'},5,'double');
fmc.quatmax2 = cos(fmc.quatmax/2*degree);
fmc.gammaW   = get_option(varargin,{'gammaW'},25,'double');
fmc.alpha    = get_option(varargin,{'alpha'},0.2,'double');
fmc.beta     = get_option(varargin,{'beta'},0.3,'double');

fmc.A_D      = A_D;

[AllPs,AllSals,numClusters] = FMC_MTEX(fmc);

assignments = FMC_interpret(AllSals, numClusters, AllPs, A_D, fmc.beta);

criterion = assignments(Dl,1) == assignments(Dr,1) & assignments(Dl,1) > 0;

% I_DG = sparse(1:length(assignments),assignments(:,1),1);
% I_DG(:,all(I_DG==0,1)) = [];

