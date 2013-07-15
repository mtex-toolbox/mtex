function [AllPs,AllSals,numClusters] = FMC_MTEX(fmc)

%% setup Wnext
[i,j] = find(fmc.A_D);  % list of cells
N     = size(fmc.A_D,1);

q     = inverse(fmc.O(i)).*fmc.O(j);
del   = real(2*acosd(max(abs(dot_outer(q,fmc.CS)),[],2))); 

fmc.Wnext = sparse(i, j, exp(-fmc.cmaha0*(del)), N, N);
clear q del

%% RunFMC
disp('starting RunFMC')
fmc.Wnext = fmc.Wnext + fmc.Wnext';
fmc.A_D = fmc.A_D | fmc.A_D';


%%

AllPs = cell(1);
numClusters = size(fmc.Wnext,1);

%v contains the number of data points in each node
fmc.v=ones(numClusters,1);  

%Sal is the saliency of each node
fmc.Sal=Inf*ones(numClusters,1);

% 
AllSals    = cell(1);
AllSals{1} = fmc.Sal;
fmc.Varin  = zeros(N,1);

% Initialize the matrix that will hold all the seed for each s level
fmc.sSeeds = [];

%Coarsen repeatedly until the size of W doesn't change
fmc.sizeW = 0;
fmc.sizeWnext = N;

%s is the iteration number
fmc.s = 1;

%storage=[struct('Ps', speye(length(Wnext)))];
fmc.P = speye(N);


while ~isequal(fmc.sizeW,fmc.sizeWnext)
     fprintf('S-Level: %i\n', fmc.s)
     fprintf('Number of Clusters: %i\n', numClusters(fmc.s))
     
     fmc.W     = fmc.Wnext;
     fmc.sizeW = fmc.sizeWnext;

     fmc = FMC_Coarsen(fmc);
     
     fmc.O     = fmc.Ocoarse; 
     fmc.Wnext = fmc.Wcoarse;
     fmc.v     = fmc.vcoarse;
     fmc.A_D   = fmc.A_Dcoarse;
     fmc.Varin = fmc.Qvar;
                  
     fmc.s = fmc.s+1;
     
     AllPs{fmc.s}       = fmc.P;
     AllSals{fmc.s}     = fmc.Sal;
     numClusters(fmc.s) = size(fmc.Wnext,1);

end

AllSals = vertcat(AllSals{:});

clear W; clear Wnext; clear Sal; clear v;
clear links; clear Aves; clear Varin;





