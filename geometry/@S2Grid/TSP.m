function varargout = TSP(S2,varargin)
% traveling salesman problem on the 2 dimensional unit-sphere with
% christophides algorithm
%
%% flags
% noTwoOpt       - omit two--opt optimization
% direct         - tsp-path sorted as input
% manhatten|polar - azimuthal/polar--metric
%
%%
%

v = vector3d(unique(S2(:)));
n = numel(v);

if ~check_option(varargin,'direct')
  A = VoronoiAdjacency(v);

  % add second and third order voronoi-neighbours;
  A = A + A*A + A*A*A;

  weight   = movingTime(A,v,varargin{:});

  mst      = MinimumSpanningTree(weight);
  matching = MinimumWeightMatching(v,weight,mst,varargin{:});
  tour     = EulerCycle(n,[mst;matching]);
  tsp      = EulerToHamiltonian(n,tour);
  edgeList = [mst;matching];
else
  tsp = [1:n 1]';
  edgeList = [1:n-1;2:n]';
end

if ~check_option(varargin,'noTwoOpt')
  A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
  A = A+A'>0;

  weight   = movingTime(ones(size(A)),v,varargin{:});
  tsp      = twoOpt(tsp,weight);
end

if nargout<1
  plot(v(tsp),'line','color','b',varargin{:})
end

if nargout>0
  varargout{1} = S2Grid(v(tsp));
end

if nargout>1
  weight   = movingTime(sparse(tsp(1:end-1),tsp(2:end),1,n,n),v,varargin{:});
  time     = full(sum(weight(:)));
  varargout{2} = time;
end




%% sub-function part
function t = movingTime(A,v,varargin)

[i,j] = find(triu(A,1));

if check_option(varargin,{'manhatten','polar'})
  
  [thetai,rhoi] = polar(v(i));
  [thetaj,rhoj] = polar(v(j));
  
  t = abs(angle(exp(1i*thetai)./exp(1i*thetaj))) + ...
    abs(angle(exp(1i*rhoi)./exp(1i*rhoj)));
  
else
  
  t = angle(v(i),v(j));
  
end

t = sparse(i,j,t,size(A,1),size(A,2));
t = t+t';


function A = VoronoiAdjacency(v,varargin)

[ignore,D] = calcVoronoi(S2Grid(v));

c = [0 ; cumsum(cellfun('prodofsize',D))];

% vertices incident to cell
iv = [D{:}];

% cell index
id = zeros(c(end),1);
for k=1:numel(D)
  id(c(k)+1:c(k+1)) = k;
end

I_VC = sparse(id,iv,1);
A = double(triu(I_VC*I_VC'>1));


function mst = MinimumSpanningTree(weight)
% returns minimum spanning tree as edgelist [start-node,end-node]

n = size(weight,1);

inTree = false(n,1);
inTree(1) = true;

lastPos = ones(n,1);

%distance to nodes in tree
d = Inf(n,1);

nd = weight(:,1) ~= 0;
d(nd) = weight(nd,1);
mst = zeros(n-1,2);

for k=2:n
  
  posInTree = find(~inTree);
  [ignore,pos] = min(d(posInTree));
  pos = posInTree(pos);
  
  mst(k-1,1) = lastPos(pos);
  mst(k-1,2) = pos;
  
  inTree(pos) = true;
  
  nd = d > weight(:,pos) & weight(:,pos) ~= 0 ;
  
  d(nd) = weight(nd,pos);
  lastPos(nd) = pos;
  
end


function matching = MinimumWeightMatching(v,weight,edgeList,varargin)
% returns minimum weight matching of odd-nodes as edge list
% [start-node,end-node]

n = size(weight,1);

isOdd  = isOddNode(numel(v),edgeList);
oddPos = find(isOdd);

% if there are to many odd-nodes, don't process the complete sub-graph
if nnz(isOdd) < 1000
  Asub = double(isOdd)*isOdd';
  weight = movingTime(Asub,v);
end

% delete edges from the weight-matrix, if they are already given
A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
A = A+A'>0;
weight(A>0) = 0; % remove already existing edges

% reduce weight matrix to odd nodes only
weight = weight(isOdd,isOdd);

% sort the entries as ascending edge list [i,j]
[i,j,w] = find(triu(weight,1));
[w, ndx] = sort(w);

edges = [i,j];
edges = edges(ndx,:);

% number of edges we have to process
n = size(weight,1)/2;
% edge list pointer
matching = zeros(n,2);


for k=1:n
  
  % the first entries is the edge with the minimum moving time
  matching(k,:) = edges(1,:);
  
  % delete edges with nodes i or j
  edges(any(edges == matching(k,1) | edges == matching(k,2),2),:) = [];
  
  if isempty(edges)
    % process remaining odd edges of incomplete graph.
    
    % make the graph komplete
    isOdd = ~isOddNode(2*n,matching(1:k,:));
    
    weight = movingTime(double(isOdd)*isOdd',v);
    
    % sort the entries as ascending edge list [i,j]
    [i,j,w] = find(triu(weight,1));
    [w, ndx] = sort(w);
    
    edges = [i,j];
    edges = edges(ndx,:);
    
  end
end

% get the old position of the nodes
matching = oddPos(matching);


function isOdd = isOddNode(n,edgeList)
% return false if node is even and true if node is odd

A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
isOdd = mod(sum((A+A')>0,2),2) > 0;


function tour = EulerCycle(n,edgeList)
% returns an euler cycle of an edgeList as a node-list

% convert the edgeList to a cell array
% adjacency matrix
A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
A = A+A';

% each cell contains the nodes adjacent to this node
edgeList = cell(n,1);
[i,j] = find(A);
for k=1:numel(j)
  edgeList{j(k)}(end+1) = i(k);
end

% degree of a node
degree = cellfun('prodofsize',edgeList);

stack = zeros(n,1);
stack(1) = 1;

top = 1;
nextEdge = 0;

tour = zeros(n,1);
while top>0
  
  i = stack(top);
  
  if degree(i)>0
    
    top = top+1;
    
    j = edgeList{i}(degree(i));
    edgeList{j} ...
      (edgeList{j} == i) = [];
    
    stack(top) = j;
    
    degree(i) = degree(i)-1;
    degree(j) = degree(j)-1;
    
  else
    
    top = top-1;
    
    nextEdge = nextEdge+1;
    tour(nextEdge) = i;
    
  end
  
end


function tsp = EulerToHamiltonian(n,tour)

visitedNode = false(n,1);
tsp = zeros(n+1,1);

index=1;
for i=1:numel(tour)
  if ~visitedNode(tour(i))
    
    tsp(index) = tour(i);
    visitedNode(tour(i)) = true;
    
    index=index+1;
    
  end
end

tsp(end) = tsp(1);


function tour = twoOpt(tour,weight)

weight = full(weight); % faster indexing

n = size(weight,1);
sub = @(k,l) (l(:)-1)*n + k(:);
[i,j] = find(triu(weight,1));

gain=Inf;

while abs(gain) > 0.01
  
  % edge        % next edge
  a = tour(i);  an = tour(i+1);
  b = tour(j);  bn = tour(j+1);  
  
 [gain ndx] = min(...
   weight(sub(b,a )) + weight(sub(bn,an)) -...
   weight(sub(b,bn)) - weight(sub(a ,an)) ); 
  
  if abs(gain)>1e-6
    tour(i(ndx)+1:j(ndx)) = tour(j(ndx):-1:i(ndx)+1);
  end
 
end

