function [assignments] = FMC_interpret(AllSals, numClusters, AllPs, A_D, beta)
%% Interpretation of FMC data and grain assignment

%% run interpret 3D


A_D = A_D|A_D';

[i,~] = find(A_D);
cs = [0 full(cumsum(sum(A_D)))];

NNlist = cell(size(A_D,1),1);
for k = 1:size(A_D,1)
   NNlist{k} = i(cs(k)+1:cs(k+1))';
end

%% sort by saliency
% sort all course nodes for all s by saliency from lowest to highest
[tmp,elements] = sort(AllSals,'ascend'); %elements is list of indices representing the sorted AllSals list
% all points assigned to own node Nx2 [assignment,confidence]
% pointData is euler1 euler2 euler3 x y z confidence
numPoints = numClusters(1);
assignmentsX=zeros(numPoints,1);  % assignment of each poing
assignmentsY=zeros(numPoints,1);  % probability of that assignment

%% s values of each node
% vector sAssign has s value of all nodes
numS = length(numClusters); %number of iterations of s
sAssign=ones(numClusters(1),1); %initiating sAssign
lengthsub=zeros(1,numS);


%1 spot in sAssign for each node, increasing number for each saliency set
for curS=2:numS
    sAssign=[sAssign; curS*ones(numClusters(curS),1)];    
end

% build assignments
for curS = numS-4:numS
    vdisp(['Considering S = ', int2str(curS)]);
    
    %find nodes for current s
    elemS = elements(sAssign(elements) == curS)';   %nodes of curS
    sLen = numClusters(curS);
    numNodes = length(elemS);   
  
    % for each s from current s to s=1, iteratively find which nodes
    % are inside of the node by multiplying by Ps
    backPs = AllPs{curS};
    for iterS=curS-1:-1:2
        backPs=AllPs{iterS}*backPs;
    end
    
    % find probability of points assigned to each node
    allUs = [backPs assignmentsY];    
    
    %assign clusters to points based on the strongest probability of any
    %point in the cluster
    [Prob, NodeIndex] = max(allUs,[],2);   
    %assign clusters to points based on the strongest probability of any
%     %point in the cluster
    allUs = allUs >= beta;
    
    for point = find((NodeIndex <= numNodes) & (Prob < 1))'
      nodePoints = allUs(:,NodeIndex(point));
      assignmentsX(nodePoints) = NodeIndex(point);
      assignmentsY(nodePoints) = Prob(point);
    end
    
    
end

%% Break up non-continuous (Michigan) clusters
rLimit = 15;   %Recursion limit (MATLAB tends to crash around 840)
%N.B. This runs considerably faster with a low recursion limit due to
%MATLAB's huge overhead. Better to make more calls than fewer, deeper calls
% set(0,'RecursionLimit',rLimit)

vdisp('Breaking non-continuous clusters')

flag = zeros(length(assignmentsX),1);
assignmentsN = zeros(length(assignmentsX),1);
contPoints = [];
for point = 2:length(flag)
    if assignmentsN(point) == 0
        oldClust = assignmentsX(point);
        newClust = point;
        if (flag(point)>1)     %if the point has been reserved, continue the same grouping
            newClust = flag(point);
        end
        assignmentsN(point) = newClust;
        rDepth = 1;

        [assignmentsN, flag, contPoints] = clusterBreaker(assignmentsN, point, assignmentsX, flag, NNlist, oldClust, newClust, contPoints, rDepth, rLimit-5);
        
        while isempty(contPoints) == 0
            pointC = contPoints(1);
            contPoints = contPoints(2:end);
            assignmentsN(pointC) = newClust;
            rDepth = 1;
            [assignmentsN, flag, contPoints] = clusterBreaker(assignmentsN, pointC, assignmentsX, flag, NNlist, oldClust, newClust, contPoints, rDepth, rLimit-5);
        end
    end
end

singlePoints = find(flag == -1 & sum(A_D,2)>1);
for pt = singlePoints'
assignmentsN(pt) = assignmentsN(NNlist{pt}(2));
end

assignmentsX = assignmentsN;
% set(0,'RecursionLimit',500)


assignments = [assignmentsX assignmentsY];
    
end
