function [AllPs,AllSals,numClusters] = FMC_MTEX(fmc)

% setup Wnext
[i,j] = find(fmc.A_D);  % list of cells
N     = size(fmc.A_D,1);

q     = inv(fmc.O(i)).*fmc.O(j);

d     = abs(dot(q,quaternion.id));
checkSym = d < cos(20/2*degree);
if any(checkSym)
  d(checkSym) = max(abs(dot_outer(q(checkSym),fmc.CS.rot)),[],2);
end
del   = 2*real(acosd(d));

% compute all misorientations
% [i,j] = find(fmc.A_D);
% del = angle(fmc.O(i),fmc.O(j));


fmc.W = sparse(i, j, exp(-fmc.cmaha0*(del)), N, N);
clear q del

% RunFMC
vdisp('starting RunFMC')
fmc.W = fmc.W + fmc.W';
% make adjecency matrix symmetric
fmc.A_D = fmc.A_D | fmc.A_D';

%

AllPs = cell(1);
numClusters = size(fmc.W,1);

%v contains the number of data points in each node
fmc.v=ones(numClusters,1);

%Sal is the saliency of each node
fmc.Sal=Inf*ones(numClusters,1);

%
AllSals    = cell(1);
AllSals{1} = fmc.Sal;
fmc.Qvar   = zeros(N,1);

% Initialize the matrix that will hold all the seed for each s level
fmc.sSeeds = [];

%Coarsen repeatedly until the size of W doesn't change
fmc.sizeW = 0;
fmc.sizeWnext = N;

%s is the iteration number
fmc.sLevel = 1;

%storage=[struct('Ps', speye(length(Wnext)))];
fmc.P = speye(N);

while ~isequal(fmc.sizeW,fmc.sizeWnext)
  
  vdisp(['S-Level: ' int2str(fmc.sLevel)]);
  vdisp(['Number of Clusters: ' int2str(numClusters(fmc.sLevel))]);
  
  fmc = FMC_Coarsen(fmc);
  
  fmc.sLevel = fmc.sLevel+1;
  
  AllPs{fmc.sLevel}       = fmc.P;
  AllSals{fmc.sLevel}     = fmc.Sal;
  numClusters(fmc.sLevel) = size(fmc.W,1);
  
end

AllSals = vertcat(AllSals{:});

clear W; clear Wnext; clear Sal; clear v;
clear links; clear Aves; clear Varin;





