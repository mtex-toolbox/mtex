function [ebsdGrid,newId] = squarify(ebsd,varargin)

uc = get_option(varargin,'unitCell',ebsd.unitCell);

% generate regular grid
prop = ebsd.prop;
ext = ebsd.extend;
dx = max(uc(:,1))-min(uc(:,1));
dy = max(uc(:,2))-min(uc(:,2));

[prop.x,prop.y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
sGrid = size(prop.x);

% if original unit cell was to much different
if numel(ebsd.unitCell) ~= 8 || 1.5*max(ebsd.unitCell(:)) < max(uc(:))
  
  % interpolate
  ebsd = interp(ebsd,prop.x,prop.y);

  ebsdGrid = EBSDsquare(reshape(ebsd.rotations,size(prop.x)),...
    ebsd.phaseId(:), ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',ebsd.prop);
  
  return
  
end

% detect position within grid
newId = sub2ind(sGrid, 1 + round((ebsd.prop.y - ext(3))/dy), ...
  1 + round((ebsd.prop.x - ext(1))/dx));

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
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
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

ebsdGrid = EBSDsquare(rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop);

end