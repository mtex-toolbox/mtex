function varargout = TSP(S2,varargin)
% traveling salesman problem on the 2 dimensional unit-sphere with
% christophides algorithm
%
%% flags
% direct  
% 2opt
% christophides|chris
% christophides2opt|chris2opt
% linkern
% concorde
% lkh
%
%%
%

v = vector3d(S2(:));
n = numel(v);

method = get_option(varargin,'method','christophides2opt');

if check_option(varargin,'voronoi')
  A = VoronoiAdjacency(v);
  A = A + A*A + A*A*A; % add second and third order voronoi-neighbours;
else
  A = ones(numel(v));
end

weight   = dist(A,v,varargin{:});

switch lower(method)
  case 'direct'
    
    tour = [1:n 1];
    
  case '2opt'
    
    tour = [1:n 1];
    tour = twoOpt(tour,weight,varargin{:});
    
  case {'christophides','chris'}
    
    tour = ChristophidesHeuristics(weight,varargin{:});
    
  case {'christophides2opt','chris2opt'}
    
    tour = ChristophidesHeuristics(weight,varargin{:});
    tour = twoOpt(tour,weight,varargin{:});

  otherwise
    
    tour = runTSPexternal(method,weight,varargin{:});
    
end

tour = tour(:);

if nargout<1
  
  time = sum(dist([tour(1:end-1) tour(2:end)],v,varargin{:}));
   figure,
  plot(v(tour),'line','color','b',varargin{:})
  title(num2str(time))
end

if nargout>0
  varargout{1} = S2Grid(v(tour));
end

if nargout>1,
  varargout{2} = tour;
end

if nargout>2,
  varargout{3} = sum(dist([tour(1:end-1) tour(2:end)],v,varargin{:}));
end



%% sub-function part
function t = dist(A,v,varargin)

if size(A,2) > 2 && size(A,1) == size(A,2)
  [i,j] = find(triu(A,1));
  n = size(A,1);
elseif size(A,2) == 2
  i = A(:,1);
  j = A(:,2);
  n = max(A(:));
end

metric = get_option(varargin,{'metric','metrics'},'angle');

switch lower(metric)
  case {'manhatten','polar'}
    
    [theta,rho] = polar(v);
    
    t = abs(angle(exp(1i*theta(i))./exp(1i*theta(j)))) + ...
      abs(angle(exp(1i*rho(i))./exp(1i*rho(j))));
    
  case 'goniometer'
    
    [theta,rho] = polar(v);
    
    d_chi = abs(angle(exp(1i*theta(i))./exp(1i*theta(j))))/degree;
    d_phi = abs(angle(exp(1i*rho(i))./exp(1i*rho(j))))/degree;
    
    s_chi = get_option(varargin,{'ChiSpeed','SpeedChi'},[1 0]);
    if numel(s_chi)>1
      d_chi = d_chi*s_chi(1) + s_chi(2);
    else
      d_chi = d_chi*s_chi(1);
    end
    
    s_phi = get_option(varargin,{'PhiSpeed','SpeedPhi'},[1 0]);
    if numel(s_phi)>1
      d_phi = d_phi*s_phi(1) + s_phi(2);
    else
      d_phi = d_phi*s_phi(1);
    end
    
    t = max(d_chi,d_phi);
    
  case 'dot'
    
    t = 1-dot(v(i),v(j)).^2;
    
  case 'angle'
    
    t = angle(v(i),v(j));
    
  otherwise
    
    error('mtex:TSP','unknown metric')
    
end

if size(A,2) > 2
  t = sparse(i,j,t,n,n);
  t = t+t';
end


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


function tour = ChristophidesHeuristics(weight,varargin)

mst      = MinimumSpanningTree(weight);
matching = MinimumWeightMatching(weight,mst);
tour     = EulerCycle([mst;matching]);
tour     = EulerToHamiltonian(tour);


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


function matching = MinimumWeightMatching(weight,edgeList)
% returns minimum weight matching of odd-nodes as edge list
% [start-node,end-node]

n = max(edgeList(:));

A = sparse(edgeList(:,1),edgeList(:,2),true,n,n);
A = A+A';
degree = full(sum(A,1));

isOdd = logical(mod(degree(:),2));
oddPos = find(isOdd);

% delete edges from the weight-matrix, if they are already given
A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
A = A+A'>0;
% remove already existing edges
weight(A>0) = Inf; % remove already existing edges

% reduce weight matrix to odd nodes only
weight = weight(isOdd,isOdd);

% sort the entries as ascending edge list [i,j]
[i,j,w] = find(triu(weight,1));
[w, ndx] = sort(w);

edges = [i(ndx),j(ndx)];
% edges = edges(ndx,:);

% number of edges we have to process
n = size(weight,1)/2;
% edge list pointer
matching = zeros(n,2);

for k= 1:n
  % the first entries is the edge with the minimum moving time
  matching(k,:) = edges(1,:);
  
  % delete edges with nodes i or j
  del = any(edges == matching(k,1) | edges == matching(k,2),2);
  
  edges(del,:) = [];
  
end

% get the old position of the nodes
matching = oddPos(matching);


function tour = EulerCycle(edgeList)
% returns an euler cycle of an edgeList as a node-list

% convert the edgeList to a cell array
% adjacency matrix
n = max(edgeList(:));

A = sparse(edgeList(:,1),edgeList(:,2),1,n,n);
A = A+A';
[i,j] = find(A);

% each cell contains the nodes adjacent to this node
edgeList = cell(n,1);

ndx = 1:size(A,2);

i = ndx(i);
j = ndx(j);
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
    tour(nextEdge) = (i);
    
  end
  
end

nn = [];
nn(ndx) = 1:numel(ndx);
tour = nn(tour);


function hamiltonianPath = EulerToHamiltonian(tour)

n = max(tour(:));
visitedNode = false(n,1);
hamiltonianPath = zeros(n+1,1);

index=1;
for i=1:numel(tour)
  if ~visitedNode(tour(i))
    hamiltonianPath(index) = tour(i);
    visitedNode(tour(i)) = true;
    
    index=index+1;
  end
end

hamiltonianPath(end) = hamiltonianPath(1);


function tour = twoOpt(tour,weight,varargin)

weight = full(weight); % faster indexing
% weight(weight==0) = Inf;
% n = size(weight,1);
n = numel(tour)-1;
maxTime = get_option(varargin,'maxtime',Inf);
s = tic;

if numel(tour)< 3, return; end

while toc(s) < maxTime
  A = weight(tour(1:end-1),tour(2:end));
  
  dA = diag(A); % diagonal entries are no the tour length (a,a+1) , (b,b+1)
  
  %   % ab-aan;
  AB = bsxfun(@minus,A,dA);
  AB = AB(1:n-1,1:n-1);
  % anbn-bbn
  CD = bsxfun(@minus,A(:,2:end),dA(2:end)');
  CD(1,:) =[];
  gain = AB+CD;
  
  % the upper triangle contains the gain.
  gain = triu(gain,1);
  
  [bestgain,pos] = min(gain(:));
  
  [besti,bestj] = ind2sub(size(gain),pos);
  
  if besti < bestj
    tour(1+(besti:bestj)) = tour(1+(bestj:-1:besti));
  end
  if bestgain >= 0, break; end
  
end


function tour = runTSPexternal(method,weight,varargin)

tsp_file = createTSPLIB95file(weight);
sol_file = [tsp_file(1:end-4) '.sol'];

cmd = fullfile(get_mtex_option('TSPSolverPath'),method);

options = get_option(varargin,method,{},'cell');

switch lower(method)
  case 'lkh'
    problem_file = [tsp_file(1:end-4) '.problem'];
    fid = fopen(problem_file,'w');
    
    fprintf(fid,'PROBLEM_FILE = %s\n',tsp_file);
    fprintf(fid,'OUTPUT_TOUR_FILE = %s\n',sol_file);
    for k=1:numel(options)
      fprintf(fid,'%s \r\n',options{k});
    end
    
    fclose(fid);
    cmd = [cmd ' ' problem_file ];
  case {'linkern','concorde'}
    
    if ispc  % cygwin
      sol_file1 = regexprep(sol_file,'\\','/');
      tsp_file1 = regexprep(tsp_file,'\\','/');
      
      sol_file1 = regexprep(sol_file1,'(\w(?=:)):|','/cygdrive/$1');
      tsp_file1 = regexprep(tsp_file1,'(\w(?=:)):','/cygdrive/$1');
    else
      sol_file1 = sol_file;
      tsp_file1 = tsp_file;
    end
    
    
    options = strcat(options,{' '});
    
    cmd = [cmd ' -o ' sol_file1 ' ' options{:}  tsp_file1 ' '];
    
end

if check_option(varargin,'silent')
  [a,b] = system(cmd);
else
  system(cmd);
end


% read solution file
fid = fopen(sol_file,'r');
switch lower(method)
  case 'lkh'
    
    tour = textscan(fid,'%d','HeaderLines',6);
    tour = tour{1}([1:end-1 1]);
    
  case 'concorde'
    
    tour = textscan(fid, '%d');
    tour = tour{1}([2:end 2])+1;
    
  case 'linkern'
    
    tour = textscan(fid,'%d','HeaderLines',1);
    tour = tour{1}([1:3:end 1])+1;
    
end
fclose(fid);

state = recycle;
recycle('off');
if exist('tsp_file','var'), delete(tsp_file); end
if exist('sol_file','var'), delete(sol_file); end
if exist('problem_file','var'),  delete(problem_file); end
recycle(state);


function [fname] = createTSPLIB95file(weight)


t = full(round(weight*10000));
fname = [tempname(get_mtex_option('tempdir')) '.tsp'];

fid = fopen(fname,'w');

fprintf(fid,'NAME: tour\r\n');
fprintf(fid,'TYPE: TSP\r\n');
fprintf(fid,'COMMENT: tour\r\n');
fprintf(fid,'DIMENSION: %d\r\n',size(weight));
fprintf(fid,'EDGE_WEIGHT_TYPE: EXPLICIT\r\n');
fprintf(fid,'EDGE_WEIGHT_FORMAT: FULL_MATRIX\r\n');
fprintf(fid,'DISPLAY_DATA_TYPE: TWOD_DISPLAY\r\n');
fprintf(fid,'EDGE_WEIGHT_SECTION\r\n');
fprintf(fid,'%d ',t);
fprintf(fid,'\r\nEOF\r\n');

fclose(fid);

