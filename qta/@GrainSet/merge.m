function [grains,I_PC] = merge(grains, property, varargin)
% merge grains with special boundary
%
% The function merges grains where the special boundary is determined by
% the function <GrainSet.specialBoundary.html specialBoundary>
%
%% Input
% grains  - @GrainSet
% property - colorize a special grain boundary property, variants are:
%
%    * double -- a single number for which the misorientation  angle is lower or
%            an interval [a b]
%
%    *  @quaternion | @rotation | @orientation -- plot grain boundaries with
%            a specified misorientation
%
%            plot(grains,'property',...
%               rotation('axis',zvector,'angle',60*degree))
%
%    *  @Miller -- plot grain boundaries such as specified
%            crystallographic face are parallel. use with option 'delta'
%
%    *  @vector3d -- axis of misorientation
%
%% Options
%  delta - specify a searching radius for special grain boundary
%            (default 5 degrees), if a orientation or crystallographic face
%            is specified.
%
%  ExclusiveGrains - a subset of grains of the given grainset marked in a
%    logical Nx1 array
%
%  ExclusiveNeighborhoods - an adjacency matrix of neighbored grains or a
%    Nx2 array indexing the neigborhoods
%
%  TripleJunction - return faces between two adjacent grains satisfying the
%    input property, if there is a triple junction with a thrid grain,
%    satisfying the property specified after TripleJunction.
%
%  ThirdCommonGrain - return faces between two adjacent grains satisfying the
%    input property, if there is a third commongrain, satisfying the
%    property specified after ThirdCommonGrain.
%
%% Output
% grains - @GrainSet
% I_PC   - incidence matrix with Parents x Childs
%
%% Syntax
% [g,I_PC] = merge(grains,property,...,param,val,...) - merges neighbored grains
%   whos common boundary satisfies |property| and returns also an matrix
%   parents vs. childs
%
% g = merge(grains,[0 10]*degree) - merges grains whos misorientation angle
%  lies between 0 and 10 degrees
%
% g = merge(grains,CSL(3))        - merges grains with special boundary CSL3
%
%% See also
% EBSD/calcGrains GrainSet/specialBoundary

%% Determine the boundaries, which should be merged

f = specialBoundary(grains,property,varargin{:},'PhaseRestricted');

% delete faces that satisfy the criterion
I_FD = grains.I_FDext | grains.I_FDint;
I_FD(f,:) = false;

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
grains.A_G = A_G > 0;

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
I_FDint = D_Fsub*I_FD;

% retrive old boundary edge orientation
I_FD = grains.I_FDext + grains.I_FDint;
I_FDext(logical(I_FDext)) = I_FD(logical(I_FDext));
I_FDint(logical(I_FDint)) = I_FD(logical(I_FDint));

grains.I_FDext = I_FDext;
grains.I_FDint = I_FDint;

%% sort edges of boundary when 2d case

if isfield(grains.options,'boundaryEdgeOrder')
  
  grains.options.boundaryEdgeOrder = BoundaryFaceOrder(I_PC,grains.options.boundaryEdgeOrder, grains.F, I_FDext, I_DG);
  
end

%% update phase

[parent,child] = find(I_PC);
phase(parent) = grains.phase(child);
grains.phase = phase;

%% update mean orientation

unchanged = sum(I_PC,2)==1;  % unchanged

if any(~unchanged) % some of the were merged  
  
  CS = get(grains,'CSCell');
  SS = get(grains,'SS');
  r  = get(grains.EBSD,'quaternion');

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
  mis2mean = inv(r(d)).* reshape(meanRotation(g),[],1);
  
  grains.EBSD = set(grains.EBSD,'mis2mean',mis2mean);
end


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

