%% setup Wnext
CS = get(ebsd,'CS');
[Dl,Dr] = find(A_D);  % list of cells
N = length(A_D);

O = quaternion(get(ebsd,'rotations'));
q = O(Dl)'.*O(Dr);
del =  real(2*acosd(max(abs(dot_outer(q,CS)),[],2))); 


Wn = exp(-cmaha0*(del));
Wnext = sparse(Dl, Dr, Wn, N, N);
clear q del Wn

%% RunFMC
disp('starting RunFMC')
Wnext = Wnext + Wnext';
A_D = A_D | A_D';



%%

AllPs = cell(1);
numClusters = size(Wnext,1);

%v contains the number of data points in each node
v=ones(numClusters,1);  

%Sal is the saliency of each node
Sal=Inf*ones(numClusters,1);

% 
AllSals=Sal;
Varin=zeros(length(Wnext),1);

% Initialize the matrix that will hold all the seed for each s level
sSeeds = [];

%Coarsen repeatedly until the size of W doesn't change
sizeW = 0;
sizeWnext = N;

%s is the iteration number
s = 1;

%storage=[struct('Ps', speye(length(Wnext)))];
P = speye(length(Wnext));


while ~isequal(sizeW,sizeWnext)
     fprintf('S-Level: %i\n', s)
     fprintf('Number of Clusters: %i\n', numClusters(s))
     
     W=Wnext; clear Wnext;
     sizeW = sizeWnext;

     FMC_Coarsen
     
     O = Ocoarse; clear Ocoarse;
     Wnext = Wcoarse; clear Wcoarse;
     v = vcoarse; clear vcoarse;
     A_D = A_Dcoarse; clear A_Dcoarse;
     Varin = Qvar; clear Qvar;
                  
     s = s+1;
     
     AllPs{s} = P;
     AllSals = [AllSals;Sal];
     numClusters(s) = size(Wnext,1);

end

clear W; clear Wnext; clear Sal; clear v;
clear links; clear Aves; clear Varin;





