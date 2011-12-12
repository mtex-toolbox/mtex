function plotGrains(grains,varargin)



V = full(get(grains,'V'));
boundaryEdgeOrder = get(grains,'boundaryEdgeOrder');

phaseMap = get(grains,'phaseMap');
phase = get(grains,'phase');


nphase = numel(phaseMap);
X = cell(1,nphase);
for k=1:nphase
  iP =  phase == phaseMap(k);
  X{k} = boundaryEdgeOrder(iP);
  
  [d{k},property] = calcColorCode(grains,iP,varargin{:});
end

boundaryEdgeOrder = vertcat(X{:});
d = vertcat(d{:});


newMTEXplot;
[V(:,1),V(:,2),lx,ly] = fixMTEXscreencoordinates(V(:,1),V(:,2),varargin{:});

% set direction of x and y axis
xlabel(lx);ylabel(ly);


h = plotFaces(boundaryEdgeOrder,V,d,varargin{:});

% legend(h)
% remove from legend for splitted patches
% setLegend(h(2:end),'off');
%

fixMTEXplot;
set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
optiondraw(h,varargin{:});



function h =plotFaces(boundaryEdgeOrder,V,d,varargin)

% add holes as polygons
hole = cellfun('isclass',boundaryEdgeOrder,'cell');

holeEdgeOrder = cellfun(@(x) x(2:end),boundaryEdgeOrder(hole),'UniformOutput',false);
holeEdgeOrder = [holeEdgeOrder{:}];
boundaryEdgeOrder(hole) = cellfun(@(x) x{1},boundaryEdgeOrder(hole),'UniformOutput',false);

% add add the holes to the list of polygons
ply = [holeEdgeOrder(:); boundaryEdgeOrder(:)];

d(numel(holeEdgeOrder)+(1:end),:) = d;
d(1:numel(holeEdgeOrder),:) = 1;

A = cellArea(V,ply);

plyNumVertices = cellfun('prodofsize',ply);

ind = splitdata(plyNumVertices,...
  fix(log(max(plyNumVertices))/2),'ascend');

obj.FaceColor = 'flat';

for k=length(ind):-1:1
  ndx = ind{k};
  [ignore zorder] = sort(A(ndx),'ascend');
  zorder = ndx(zorder);
   
  faces = ply(zorder);
  faces = [faces{:}];
  
  v = sparse(faces,1,1,size(V,1),1);
  obj.Vertices = V(v>0,:);
    
  v = cumsum(full(v)>0);
  faces = nonzeros(v(faces));
  
  plyNumZVertices = plyNumVertices(zorder);

  obj.Faces  = NaN(numel(zorder),max(plyNumZVertices));
  
  cs = [0;cumsum(plyNumZVertices)];
  for f=1:numel(zorder)
    obj.Faces (f,1:plyNumZVertices(f))= faces(cs(f)+1:cs(f+1));
  end
  
  obj.FaceVertexCData = d(zorder,:);
  
  % plot the patches
  h(k) = optiondraw(patch(obj),varargin{:});
  
end




function A = cellArea(V,D)

D = D(:);
A = zeros(size(D));

faceOrder = [D{:}];

x = V(faceOrder,1);
y = V(faceOrder,2);

dF = full(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1));

cs = [0; cumsum(cellfun('prodofsize',D))];
for k=1:numel(D)
  ndx = cs(k)+1:cs(k+1)-1;
  A(k) = abs(sum(dF(ndx))*0.5);
end


