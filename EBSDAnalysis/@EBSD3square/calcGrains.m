function [grains,ebsd] = calcGrains(ebsd,varargin)
% grain reconstruction from 3d EBSD data on a voxel grid
%
% Syntax
%
%   [grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5)
%
%   % reconstruction low and high angle grain boundaries
%   lagb = 2*degree;
%   hagb = 10*degree;
%   grains = calcGrains(ebsd,'angle',[hagb lagb])
%
%   % grains from a grainId stored with the data, e.g. imported from a file
%   grains = calcGrains(ebsd,'grainId')
%
%   % specify phase dependent thresholds
%   % thresholds follow the same order as ebsd.CSList and should have the same length
%   grains = calcGrains(ebsd,'angle',{angle_1 angle_2 angle_3})
%
% Input
%  ebsd   - @EBSD3square
%
% Output
%  grains - @grain3d, the boundary consists of triangles, two per voxel face
%  ebsd   - @EBSD3square with additional property grainId
%
% Options
%  angle    - misorientation angle that indicates a grain boundary
%  minPixel - minimum number of voxels that form a grain. No indexed grain
%             smaller than this is returned; the voxels of one that would be
%             are marked notIndexed
%  soft     - [angle delta] soft threshold instead of a hard one
%  fmc      - fast multiscale clustering method
%  mcl      - Markovian clustering algorithm
%
% Flags
%  grainId  - connect voxels with the same ebsd.grainId instead of a
%             criterion on the orientations
%
% Description
%
% Voxels are 6-connected. A boundary face separates two neighbouring voxels
% the criterion tells apart; together with the outer hull the faces close
% every grain, so volumes follow from the divergence theorem. notIndexed
% voxels form notIndexed grains.
%
% See also
% EBSD/calcGrains grain3d grain3Boundary

gbc = grainBoundaryCriterion.byOptions(varargin{:});

% a stored grainId of 0 means no grain, as it does for the output
if check_option(varargin,'grainId'), ebsd.phaseId(ebsd.grainId == 0) = 1; end

minPixel = get_option(varargin,'minPixel',1);
if gbc.handlesMinPixel && minPixel > 1, gbc = gbc.setMinPixel(minPixel); end

sz = size(ebsd); sz(end+1:3) = 1;
id = reshape(1:prod(sz),sz);

% the 6-neighbourhood as ordered voxel pairs along each array dimension
Dl = [reshape(id(1:end-1,:,:),[],1); reshape(id(:,1:end-1,:),[],1); reshape(id(:,:,1:end-1),[],1)];
Dr = [reshape(id(2:end,:,:),[],1);   reshape(id(:,2:end,:),[],1);   reshape(id(:,:,2:end),[],1)];
dim = repelem((1:3).', prod(sz) ./ sz(:) .* (sz(:)-1));

[~,I_DG] = gbc.segment(ebsd,Dl,Dr,varargin{:});

% indexed grains below minPixel become notIndexed and are segmented again
if ~gbc.handlesMinPixel && minPixel > 1
  under = full(sum(I_DG,1)).' < minPixel & grainPhase(I_DG) > 1;
  if any(under)
    ebsd.phaseId(full(any(I_DG(:,under),2))) = 1;
    [~,I_DG] = gbc.segment(ebsd,Dl,Dr,varargin{:});
  end
end

grainId = full(I_DG * (1:size(I_DG,2)).');
phaseId = grainPhase(I_DG);

% a face is an ordered voxel pair (a,b) along dimension d, b = 0 on the hull:
% inner faces separate different grains, hull faces close the volume
isFace = grainId(Dl) ~= grainId(Dr);
lo = [reshape(id(1,:,:),[],1);   reshape(id(:,1,:),[],1);   reshape(id(:,:,1),[],1)];
hi = [reshape(id(end,:,:),[],1); reshape(id(:,end,:),[],1); reshape(id(:,:,end),[],1)];
dHull = repelem((1:3).', prod(sz) ./ sz(:));
a = [Dl(isFace); lo; hi];
b = [Dr(isFace); zeros(numel(lo)+numel(hi),1)];
d = [dim(isFace); dHull; dHull];
isLow = [false(nnz(isFace),1); true(numel(lo),1); false(numel(hi),1)];

% the face sits on the far side of a, or on the near side on the low hull
[i,j,k] = ind2sub(sz,a);
s = [i,j,k];
s(sub2ind(size(s),find(isLow),d(isLow))) = 0;

% corner offsets of the quad with normal +e_d, reversed where that points inwards
off = cat(3,[1 1 1 1; 0 0 1 1; 0 1 1 0], [0 1 1 0; 1 1 1 1; 0 0 1 1], [0 0 1 1; 0 1 1 0; 1 1 1 1]);
Q = zeros(numel(d),4);
for c = 1:4
  Q(:,c) = sub2ind(sz+1, s(:,1)+off(d,c,1), s(:,2)+off(d,c,2), s(:,3)+off(d,c,3));
end
flip = xor(isLow, det([ebsd.d1.xyz; ebsd.d2.xyz; ebsd.d3.xyz]) < 0);
Q(flip,:) = Q(flip,[1 4 3 2]);

% two triangles per quad, neighbours in the face list
T = reshape(permute(cat(3,Q(:,[1 2 3]),Q(:,[1 3 4])),[3 1 2]),[],3);
a = repelem(a,2); b = repelem(b,2);

% the corners in use, placed relative to the first voxel
[cId,~,T] = unique(T); T = reshape(T,[],3);
[ci,cj,ck] = ind2sub(sz+1,cId);
V = ebsd.pos(1) + (ci-1.5).*ebsd.d1 + (cj-1.5).*ebsd.d2 + (ck-1.5).*ebsd.d3;

% the normal points out of a and into b
f = (1:numel(a)).';
I_GF = sparse([grainId(a); grainId(b(b>0))], [f; f(b>0)], ...
  [ones(numel(a),1); -ones(nnz(b),1)], size(I_DG,2), numel(a));

grains = grain3d(V, T, I_GF, [], ebsd.CSList, phaseId, ebsd.phaseMap);
grains.numPixel = full(sum(I_DG,1)).';

% the boundary knows the voxels it separates, not only the grains
ebsdId = [ebsd.id(a), zeros(numel(a),1)];
ebsdId(b>0,2) = ebsd.id(b(b>0));
grains.boundary.ebsdId = ebsdId;
mori = rotation.nan(numel(a),1);
mori(b>0) = inv(ebsd.rotations(b(b>0))) .* ebsd.rotations(a(b>0));
grains.boundary.misrotation = mori;

% calc mean orientations, GOS and mis2mean
% ----------------------------------------

[d,g] = find(I_DG);

grainRange    = [0;cumsum(grains.numPixel)];
firstD        = d(grainRange(2:end));
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);

% choose between equivalent orientations in one grain such that all are
% close together
for pId = grains.indexedPhasesId
  ndx = ebsd.phaseId(d) == pId;
  if ~any(ndx), continue; end
  q(d(ndx)) = project2FundamentalRegion(q(d(ndx)),ebsd.CSList(pId),meanRotation(g(ndx)));
end

[meanRotation, GOS] = accumarray(grainId,q(:));

grains.prop.GOS = GOS;
grains.prop.meanRotation = reshape(meanRotation,[],1);

if nargout > 1, ebsd.grainId = grainId; end

  function phG = grainPhase(I_DG)
    phG = full(max(I_DG' * spdiags(ebsd.phaseId,0,numel(id),numel(id)),[],2));
  end

end
