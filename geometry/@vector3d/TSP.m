function varargout = TSP(S2,varargin)
% traveling salesman problem on the 2 dimensional unit-sphere
%
%% Remarks
% Option xxx2opt invokes lin-kerninghan heuristics. If no further breadth
% is specified it uses the default breadth of [1].
%% Syntax
%  TSP(S2,'metric','goniometer','chispeed',[1/2.55 4.5],'phispeed',[1/9.45 4.5]) - applies  goniometer metric
%  TSP(S2,'method','christophides2opt') - is the default method
%  TSP(S2,'method','christophides2opt',[4 3 3 2]) - sets the breadth of the
%    2opt search tree for the lin kerninghan heuristics.
%
%% Input
%  S2  - @S2Grid
%% Options
%  Method  - Selects a heuristics or external solver
%
%    * |'direct'| --
%    * |'2opt'| -- two opt heuristics
%    * |'dmst'| -- double minimum spanning tree heuristics
%    * |'dmst2opt'| -- double minimum spanning tree heuristics + 2opt improvement
%    * |'dmstdouble'| -- invokes the 2opt improvement before and after the short cut
%    * |'christophides'|,|'chris'| -- christophides heuristics
%    * |'christophides2opt'|, |'chris2opt'| -- christophides heuristics + 2opt improvement
%    * |'chrisdoubleopt'| -- invokes the 2opt improvement before and after the short cut
%    * |'insertion'| -- insertion heuristics.
%    * |'insertion2opt'| -- insertion heuristics + 2opt improvement
%    * |'linkern'| -- invoke external solver
%    * |'concorde'| -- invoke external solver
%    * |'lkh'| -- invoke external solver
%  Metric - sets the spherical metric
%
%    * |'manhatten'| -- manhatten distance on sphere.
%    * |'goniometer'| -- maximum polar angle, requires |'PhiSpeed'| and
%                        |'ChiSpeed'|.
%    * |'angle'|  -- normal spherical distance.
%  MaxTime - aborts 2-- or n--opt after given seconds if specified.
%
%%
%

v = vector3d(S2(:));
n = length(v);

method = get_option(varargin,'method','christophides2opt');

if check_option(varargin,'voronoi')
  A = VoronoiAdjacency(v);
  A = A + A*A + A*A*A; % add second and third order voronoi-neighbours;
else
  A = ones(length(v));
end

weight   = dist(A,v,varargin{:});
weight   = full(weight);

varargin = set_default_option(varargin,{'v',v});

switch lower(method)
  case 'direct'

    tour = [1:n 1];

  case 'insertion'

    tour = insertionHeuristics(weight,varargin{:});
    %     tour = twoOpt(tour,weight,varargin{:});

  case 'insertion2opt'

    tour = insertionHeuristics(weight,varargin{:});
    breadth = get_option(varargin,'insertion2opt',1,'double');
    tour = LinKern(weight,tour,breadth,varargin{:});

  case '2opt'

    tour = [1:n 1];
    breadth = get_option(varargin,'2opt',1,'double');
    tour = LinKern(weight,tour,breadth,varargin{:});

  case {'christophides','chris'}

    tour = ChristophidesHeuristics(weight,varargin{:});

  case {'christophides2opt','chris2opt'}

    tour = ChristophidesHeuristics(weight,varargin{:});
    breadth   = get_option(varargin,{'christophides2opt','chris2opt'},1,'double');
    tour = LinKern(weight,tour,breadth,varargin{:});

  case {'linkerninghan'}

    tour = ChristophidesHeuristics(weight,varargin{:});
    breath = get_option(varargin,'linkerninghan',[4 3 3 2]);
    tour = LinKern(weight,tour,breath,varargin{:});

  case {'dmst'}

    mst      = MinimumSpanningTree(weight);
    tour     = EulerCycle([mst;mst]);
    tour     = EulerToHamiltonian(tour);

  case {'dmst2opt'}

    mst      = MinimumSpanningTree(weight);
    tour     = EulerCycle([mst;mst]);
    tour     = EulerToHamiltonian(tour);
    breadth   = get_option(varargin,'dmst2opt',1,'double');
    tour     = LinKern(weight,tour,breadth,varargin{:});

  case {'dmstdouble'}

    mst      = MinimumSpanningTree(weight);
    tour     = EulerCycle([mst;mst]);
    breadth   = get_option(varargin,'dmstdouble',1,'double');
    tour     = LinKern(weight,tour,breadth,varargin{:});
    tour     = EulerToHamiltonian(tour);
    tour     = LinKern(weight,tour,breadth,varargin{:});

  case {'chrisdoubleopt','christophidesdoubleopt'}

    mst      = MinimumSpanningTree(weight);
    matching = MinimumWeightMatching(weight,mst);

    tour     = EulerCycle([mst;matching]);
    breadth   = get_option(varargin,'chrisdoubleopt',1,'double');

    tour     = LinKern(weight,tour,breadth,varargin{:});
    tour     = EulerToHamiltonian(tour);
    tour     = LinKern(weight,tour,breadth,varargin{:});

  otherwise

    tour = runTSPexternal(method,weight,varargin{:});

end

tour = tour(:);

if nargout<1

  time = sum(dist([tour(1:end-1) tour(2:end)],v,varargin{:}));
  figure,
  line(v(tour),'color','b',varargin{:})
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

    t = acos(cos(theta(i)-theta(j))) + acos(cos(rho(i)-rho(j)));

  case 'goniometer'

    [theta,rho] = polar(v);

    d_chi = acos(cos(theta(i)-theta(j)))/degree;
    d_phi = acos(cos(rho(i)-rho(j)))/degree;

    p_chi = get_option(varargin,{'ChiSpeed','SpeedChi'},[1 0]);
    d_chi = polyval(p_chi,d_chi);

    p_phi = get_option(varargin,{'PhiSpeed','SpeedPhi'},[1 0]);
    d_phi = polyval(p_phi,d_phi);

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
weight2 = weight(isOdd,isOdd);

% sort the entries as ascending edge list [i,j]
[i,j,w] = find(triu(weight2,1));
[w, ndx] = sort(w);

edges = [i(ndx),j(ndx)];
edges = edges(ndx,:);

% number of edges we have to process
n = size(weight2,1)/2;
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


function tour = LinKern(weight,tour,stack,varargin)


maxTime = get_option(varargin,'maxtime',Inf);
s = tic;

a = -Inf;

while a < 0 && toc(s) < maxTime
  [gains,tours] = LinMove(weight,tour,stack);

  [a i] = min(gains);
  tour = tours(i,:);
end


function [gain,tours] = LinMove(weight,tour,stack,g)

if nargin < 4
  g = 0;
end

[tours gain] = TwoMove(weight,tour,stack(1));

gain = gain+g;
stack(1) = [];

if ~isempty(stack)
  leaves = cell(size(gain));
  for k=1:size(tours,1)
    [leaves{k} toursk{k}] = LinMove(weight,tours(k,:),stack,gain(k));
  end

  [a i]  =  cellfun(@min,leaves);
  toursk =  cellfun(@(x,i) x(i,:),toursk,num2cell(i)','UniformOutput',false);

  tours2 = vertcat(toursk{:});

  i = a < gain;
  gain(i) = a(i);
  tours(i,:) = tours2(i,:);
  %   gain = min(gain,a);
end


function [tours,bestgain] = TwoMove(weight,tour,depth)

% n = max(tour(:))
n = numel(tour(:))-1;
tours = repmat(tour(:)',depth,1);
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

if depth == 1
  [bestgain,pos] = min(gain(:));
else
  [bestgain,pos] = sort(gain(:));
end

pos = pos(1:depth);
bestgain = bestgain(1:depth);

[besti,bestj] = ind2sub(size(gain),pos);

for k = 1:depth
  if besti(k) < bestj(k)
    tours(k,1+(besti(k):bestj(k))) = tours(k,1+(bestj(k):-1:besti(k)));
  else
    %  disp('?')
  end

end


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


[a b] = unique(tour,'first');

hamiltonianPath = zeros(size(tour));
hamiltonianPath(b) = a;
hamiltonianPath(hamiltonianPath == 0) = [];
hamiltonianPath(end+1) = hamiltonianPath(1);

function tour = insertionHeuristics(weight,varargin)


W = full(weight);
W(W==0) = inf;
tour = [1 1];

n = size(W,1);
candit = 2:n;

while ~isempty(candit)

  %   W1 = W(tour(1:end-1),candit);
  W2 = W(tour(end-1),candit);
  Wf = (W2);

  [a i] = min(Wf(:));
  [a i] = ind2sub(size(Wf),i);
  tour = [tour(1:end-1) candit(i) tour(end)];

  %   tour = [tour(1:a) candit(i) tour(a+1:end)];
  candit(i) = [];
end


function tour = runTSPexternal(method,weight,varargin)

tsp_file = createTSPLIB95file(weight);
sol_file = [tsp_file(1:end-4) '.sol'];

cmd = fullfile(getMTEXpref('TSPSolverPath'),method);

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
fname = [tempname(getMTEXpref('tempdir')) '.tsp'];

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
