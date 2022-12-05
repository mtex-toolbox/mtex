function [ebsdGrid,newId] = squarify(ebsd,varargin)

% set up the new unit cell
uc = get_option(varargin,'unitCell',ebsd.unitCell);
if isnumeric(uc), uc = vector3d(uc(:,1),uc(:,2),0); end

if length(uniquetol(uc.x,0.01)) ~= 4 || length(uniquetol(uc.y,0.01)) ~= 4
  uc = ebsd.dPos/2 * vector3d([1 1 -1 -1],[1 -1 -1 1],0);
end

% generate regular grid
ext = ebsd.extend;
dx = max(uc.x)-min(uc.x);
dy = max(uc.y)-min(uc.y);

[x,y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
pos = vector3d(x,y,0);
sGrid = size(x);

% if original unit cell was to much different
if 0 && length(ebsd.unitCell) ~= 4 || 1.5*max(norm(ebsd.unitCell)) < max(norm(uc))
  
  % interpolate
  ebsd = interp(ebsd,x,y);

  ebsdGrid = EBSDsquare(pos,reshape(ebsd.rotations,sGrid),...
    ebsd.phaseId(:), ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',ebsd.prop);
  
  return
  
end

% detect position within grid
newId = sub2ind(sGrid, 1 + round((ebsd.pos.y - ext(3))/dy), ...
  1 + round((ebsd.pos.x - ext(1))/dx));

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

ebsdGrid = EBSDsquare(pos,rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop);

end