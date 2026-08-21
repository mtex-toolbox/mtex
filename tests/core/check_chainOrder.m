function check_chainOrder
% verify chainOrderC against the MATLAB reference implementation
%
% The compiled and the MATLAB path have to agree edge for edge, not just up
% to a relabelling: grainBoundary/order turns their output into the stored
% row order of grains.boundary, so a machine without the mex file would
% otherwise produce a differently ordered - though equally valid - boundary.

if exist('chainOrderC','file') ~= 3
  error('chainOrderC is not compiled - run mex_install');
end

% ------------------------------------------------------------------ cases
% hand written graphs covering the structures order.m has to survive
cases = {};

% open path
cases{end+1} = struct('F',[1 2;2 3;3 4],'nV',4,'name','open path');

% the same path, rows shuffled and columns flipped
cases{end+1} = struct('F',[3 2;3 4;2 1],'nV',4,'name','shuffled path');

% closed loop - no junction anywhere, has to be cut at its lowest vertex
cases{end+1} = struct('F',[1 2;2 3;3 4;4 1],'nV',4,'name','closed loop');

% closed loop not containing vertex 1, cut at its own lowest vertex
cases{end+1} = struct('F',[5 3;3 4;4 5],'nV',6,'name','closed loop, offset');

% two chains meeting at a triple point
cases{end+1} = struct('F',[1 2;2 3;2 4;4 5],'nV',5,'name','triple point');

% isolated edge between two junctions
cases{end+1} = struct('F',[1 2;2 3;3 1;3 4;4 5;5 3],'nV',5,'name','theta graph');

% single edge
cases{end+1} = struct('F',[2 3],'nV',3,'name','single edge');

% two disjoint loops - both closed, exercising the per chain cut
cases{end+1} = struct('F',[1 2;2 3;3 1;4 5;5 6;6 4],'nV',6,'name','two loops');

% chain of length one attached to nothing but junctions on both sides
cases{end+1} = struct('F',[1 2;1 3;1 4;2 5;2 6;2 7],'nV',7,'name','bar bell');

for k = 1:numel(cases)
  c = cases{k};
  compareBoth(c.F,c.nV,c.name);
end

% ------------------------------------------------------- random cell walls
% a realistic mix of degree 2 vertices and junctions
rng(0);
for k = 1:25

  nV = randi([10 400]);
  nE = randi([5 3*nV]);

  F = [randi(nV,nE,1) randi(nV,nE,1)];
  F(F(:,1) == F(:,2),:) = [];          % no self loops
  F = unique(sort(F,2),'rows');        % no repeated edges
  if size(F,1) < 2, continue; end

  % half of the runs get the columns flipped at random, since order.m is
  % called on boundaries whose column order already encodes a direction
  flip = rand(size(F,1),1) < 0.5;
  F(flip,:) = fliplr(F(flip,:));

  compareBoth(F,nV,sprintf('random %d',k));
end

% ------------------------------------------------------------- a real map
ebsd = mtexdata('small','silent');
grains = calcGrains(ebsd('indexed'),'angle',10*degree);
gB = grains.boundary;
compareBoth(gB.F,size(gB.allV,1),'mtexdata small');

% the full round trip: order has to give the same permutation either way
[~,pMex] = gB.order;
gBs = gB.subSet(randperm(length(gB)).');
[~,p1] = gBs.order;
assert(isequal(sort(p1),(1:length(gB)).'),'order did not return a permutation');
assert(isequal(sort(pMex),(1:length(gB)).'),'order did not return a permutation');

disp('check_chainOrder passed');

end

% ------------------------------------------------------------------------
function compareBoth(F,nV,name)

[c1,p1,e1] = chainOrder(F,nV);
[c2,p2,e2] = chainOrder(F,nV,'noMex');

assert(isequal(c1,c2),'chainOrder: chain ids differ on "%s"',name);
assert(isequal(p1,p2),'chainOrder: positions differ on "%s"',name);
assert(isequal(e1,e2),'chainOrder: entry ends differ on "%s"',name);

checkInvariant(F,c1,p1,e1,name);

end

% ------------------------------------------------------------------------
function checkInvariant(F,cid,pos,firstEnd,name)
% independent of either implementation: the walk has to be a walk

nF = size(F,1);
nCh = max(cid);
len = accumarray(cid,1,[nCh 1]);

assert(all(cid >= 1 & cid <= nCh) && all(ismember(firstEnd,[1 2])), ...
  'chainOrder: output out of range on "%s"',name);

% within every chain pos runs 0..len-1 exactly once, which is what makes
% the destination index in order.m a permutation
dest = cumsum([0;len(1:end-1)]);
dest = dest(cid) + pos + 1;
assert(isequal(sort(dest),(1:nF).'), ...
  'chainOrder: positions are not a permutation per chain on "%s"',name);

% consecutive segments of a chain share the walked vertex
Fw = F;
sw = firstEnd == 2;
Fw(sw,:) = fliplr(Fw(sw,:));

ord = zeros(nF,1);
ord(dest) = 1:nF;
Fo = Fw(ord,:);
co = cid(ord);

same = co(1:end-1) == co(2:end);
assert(all(Fo(same,2) == Fo([false;same],1)), ...
  'chainOrder: chain is not walkable on "%s"',name);

% chains are maximal: an open chain can only end at a junction
deg = accumarray(F(:),1,[max(F(:)) 1]);
first = ord(cumsum([1;len(1:end-1)]));
last  = ord(cumsum(len));
vFirst = Fw(first,1);
vLast  = Fw(last,2);
isClosed = vFirst == vLast;
assert(all(deg(vFirst(~isClosed)) ~= 2), ...
  'chainOrder: chain start is not a junction on "%s"',name);
assert(all(deg(vLast(~isClosed)) ~= 2), ...
  'chainOrder: chain end is not a junction on "%s"',name);

end
