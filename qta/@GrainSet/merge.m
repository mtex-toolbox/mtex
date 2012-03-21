function [grains,I_PC] = merge( grains, propval, varargin )
% merg grains by boundary criterion
%
%% Input
% grains  - @GrainSet
% propval - double | @quaternion | @rotation | @orientation | @Miller
%
%% Options
% delta - searching radius in radians
%
%% Output
% grains - @GrainSet
% I_PC   - incidence matrix with Parents x Childs
%
%% Syntax
%  g = merge(grains,[0 10]*degree) - merges grains whos misorientation angle lies between 0 and 10 degrees
%  g = merge(grains,CSL(3))        - merges grains with special boundary CSL3
%
%% See also
% calcGrains

property = class(propval);

%% properties of ebsd

phase = get(grains.EBSD,'phase');
phaseMap = get(grains,'phaseMap');

CS = get(grains,'CSCell');
SS = get(grains,'SS');
r         = get(grains.EBSD,'quaternion');
phase     = get(grains.EBSD,'phase');
isIndexed = ~isNotIndexed(grains.EBSD);

%% adjacent cells on grain boundary

I_FD = grains.I_FDext | grains.I_FDsub;

sel = find(sum(I_FD,2) == 2);
[d,i] = find(I_FD(sel,any(grains.I_DG,2))');
Dl = d(1:2:end); Dr = d(2:2:end);

%% restrict to possible merge candidates, i.e same phase and indexed
% delete adjacenies between different phase and not indexed measurements

f = sel(i(1:2:end));
use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);

Dl = Dl(use); Dr = Dr(use);
phase = phase(Dl);
f = f(use);

%% find and delete adjacencies

epsilon = get_option(varargin,{'deltaAngle','angle','delta'},5*degree,'double');

for p=1:numel(phaseMap)
  currentPhase = phase == phaseMap(p);
  if any(currentPhase)
    
    o_Dl = orientation(r(Dl(currentPhase)),CS{p},SS);
    o_Dr = orientation(r(Dr(currentPhase)),CS{p},SS);
    
    m  = o_Dl.\o_Dr; % misorientation
    
    prop(currentPhase,:) = doMerge(m,property,propval,epsilon);
    
  end
end

f(~prop) = [];
I_FD(f,:) = 0; % delete incidence


%% Resegment   (see calcGrains)

I_FD = double(I_FD);
% new boundaries
A_Db = I_FD'*I_FD & grains.A_D;

A_Do = grains.A_D - A_Db; % internal adjacencies
ids = connectedComponents(A_Do|A_Do');

A_Db = A_Db|A_Db';

%% retrieve neighbours

I_DG = sparse(1:numel(ids),double(ids),1);  % voxels incident to grains
A_G = I_DG'*A_Db*I_DG;                      % adjacency of grains

% Parent x Childs
I_PC = double(I_DG'*grains.I_DG>0); % determine which cells were merged;

grains.I_DG = I_DG;
grains.A_G = A_G;

%% interior and exterior grain boundaries

sub = A_Db * I_DG & I_DG;                      % voxels that have a subgrain boundary
[i,j] = find( diag(any(sub,2))*double(A_Db) ); % all adjacence to those
sub = any(sub(i,:) & sub(j,:),2);              % pairs in a grain

d = size(grains.A_D,1);
A_Db_int = sparse(i(sub),j(sub),1,d,d);
A_Db_ext = A_Db - A_Db_int;

%% create incidence graphs

I_FDbg = diag(sum(I_FD,2)==1)*I_FD;

[ix,iy] = find(A_Db_ext);
D_Fext  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);

D_Fbg = diag(any(I_FDbg,2));
I_FDext = (D_Fext| D_Fbg)*I_FD;

[ix,iy] = find(A_Db_int);
D_Fsub  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
I_FDsub = D_Fsub*I_FD;

% retrive old boundary edge orientation
I_FD = grains.I_FDext + grains.I_FDsub;
I_FDext(logical(I_FDext)) = I_FD(logical(I_FDext));
I_FDsub(logical(I_FDsub)) = I_FD(logical(I_FDsub));

grains.I_FDext = I_FDext;
grains.I_FDsub = I_FDsub;

%% sort edges of boundary when 2d case

if isfield(grains.options,'boundaryEdgeOrder')
  
  grains.options.boundaryEdgeOrder = BoundaryFaceOrder(I_PC,grains.options.boundaryEdgeOrder, grains.F, I_FDext, I_DG);
  
end

%% update phase

[parent,child] = find(I_PC);
clear phase
phase(parent) = grains.phase(child);
grains.phase = phase;

%% update mean orientation

unchanged = sum(I_PC,2)==1;  % unchanged

[i,oldval] = find(I_PC(unchanged,:));
meanRotation(unchanged) = grains.meanRotation(oldval);
changedI_DG = I_DG(:,~unchanged);
[i,j] = find(changedI_DG);

cc = full(sum(changedI_DG,1));
cs = [0 cumsum(cc)];


for k=1:numel(cc)
  edx{k} = i(cs(k)+1:cs(k+1));
end
qcedx = partition(r,edx);

changed = find(~unchanged);
for k=1:numel(cc)
  c = changed(k);
  if ~ischar(CS{phase(k)})
    meanRotation(c) = mean_CS(qcedx{k},CS{phase(c)},SS);
  end
end

grains.meanRotation = meanRotation;

[g,d] = find(I_DG');
mis2mean = inverse(r(d)).* reshape(meanRotation(g),[],1);

grains.EBSD = set(grains.EBSD,'mis2mean',mis2mean);



function b = BoundaryFaceOrder(I_PC,boundaries,F,I_FD,I_DG)

unchanged = sum(I_PC,2)==1;  % unchanged
[i,old_unchanged] = find(I_PC(unchanged,:));
b(unchanged) = boundaries(old_unchanged);

I_FG = I_FD*I_DG;
[i,d,s] = find(I_FG);
cs = [0 cumsum(full(sum(I_FG~=0,1)))];

for k=find(~unchanged)'
  ndx = cs(k)+1:cs(k+1);
  
  E1 = F(i(ndx),:);
  s1 = s(ndx); % flip edge
  E1(s1>0,[2 1]) = E1(s1>0,[1 2]);
  
  b{k} = EulerCycles(E1(:,1),E1(:,2));
  
end

for k=find(cellfun('isclass',b(:)','cell'))
  boundary = b{k};
  [ignore,order] = sort(cellfun('prodofsize', boundary),'descend');
  b{k} = boundary(order);
end

b = b(:);


function val = doMerge(m,property,propval,epsilon)


switch property
  
  case 'double'
    
    val = angle(m(:));
    
    if numel(propval) == 2   % interval
      
      val = min(propval) <= val & val <= max(propval);
      
    else
      
      val = abs(propval-val)<= epsilon;
      
    end
    
  case {'quaternion','rotation','orientation','SO3Grid'}
    
    val = any(find(m,propval,epsilon),2);
    
  case 'vector3d'
    
    val = angle(axis(m),propval) < epsilon;
    
  case {'miller','cell'}
    % special rotation, such that m*h_1 = h_2,
    
    if strcmp(property,'cell'),
      h = [propval{[1 end]}];
    else
      h = propval;
    end
    
    if isa(h,'Miller')
      h = ensureCS(get(m,'CS'),ensurecell(h));
    end
    
    h = ensurecell(h);
    
    gr = symmetrise(vector3d(h{end}),get(m,'CS'));
    gh = symmetrise(vector3d(h{1}),get(m,'CS'));
    
    p = quaternion(m(:))*gh;
    if numel(h) > 1
      p =  [p quaternion(inverse(m(:)))*gh];
    end
    
    val =  false(size(m(:)));
    for l=1:numel(gr)
      val = val | min(angle(p,gr(l)),[],2) < epsilon;
    end
    
  otherwise
    
    error('unknown property')
    
end
