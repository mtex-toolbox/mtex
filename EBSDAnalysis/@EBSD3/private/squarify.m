function [ebsdGrid,newId] = squarify(ebsd,varargin)

% set up the new unit cell
uc = get_option(varargin,'unitCell',ebsd.unitCell);
if isnumeric(uc), uc = vector3d(uc(:,1),uc(:,2),0); end

if ~check_option(varargin,'unitCell') && ...
    (length(uniquetol(uc.x,0.01)) ~= 4 || length(uniquetol(uc.y,0.01)) ~= 4)
  uc = ebsd.dPos/2 * vector3d([1 1 -1 -1 1 1 -1 -1],...
                                       [1 -1 -1 1 1 -1 -1 1],...
                                       [1 1 1 1 -1 -1 -1 -1]);
end

ext = get_option(varargin,'extent',ebsd.extent);

% generate regular grid
dxyz = [max(uc.x)-min(uc.x), max(uc.y)-min(uc.y), max(uc.z)-min(uc.z)];
nGrid = 1 + max(0,round((ext([2 4 6]) - ext([1 3 5])) ./dxyz));

nGrid(isinf(nGrid)) = 1;

% z runs first
[x,y,z] = meshgrid(...
  linspace(ext(1),ext(2),nGrid(1)),...
  linspace(ext(3),ext(4),nGrid(2)),...
  linspace(ext(5),ext(6),nGrid(3)));

pos = vector3d(x,y,z);
sGrid = size(x);

% if original unit cell was to much different
if length(ebsd.unitCell) ~= 8 || 1.5*max(norm(ebsd.unitCell)) < max(norm(uc))
  
  % interpolate
  ebsd = interp(ebsd,pos);

  ebsdGrid = EBSDsquare(pos,reshape(ebsd.rotations,sGrid),...
    ebsd.phaseId(:), ebsd.phaseMap,ebsd.CSList,dxyz,'options',ebsd.prop,'opt',ebsd.opt);
  
  return
  
end

% detect position within grid
newId = sub2ind(sGrid, ...
  1 + round((ebsd.pos.y - ext(3))/dxyz(2)), ...
  1 + round((ebsd.pos.x - ext(1))/dxyz(1)),...
  1 + round((ebsd.pos.z - ext(5))/dxyz(3)));

% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(newId) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(newId) = ebsd.rotations.a;
b(newId) = ebsd.rotations.b;
c(newId) = ebsd.rotations.c;
d(newId) = ebsd.rotations.d;

% update all other properties
prop = ebsd.prop;
for fn = fieldnames(ebsd.prop).'
  if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
    prop.(char(fn)) = nan(sGrid);
  else
    prop.(char(fn)) = prop.(char(fn)).nan(sGrid);
  end
  prop.(char(fn))(newId) = ebsd.prop.(char(fn));
end

% store old id
prop.oldId = nan(sGrid);
prop.oldId(newId) = ebsd.id;

ebsdGrid = EBSD3square(pos,rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,dxyz,'options',prop,'opt',ebsd.opt);

end
