function [ebsdGrid,newId] = squarify(ebsd,varargin)

unitCell = get_option(varargin,'unitCell',ebsd.unitCell);
ext = get_option(varargin,'extent',ebsd.extent);
prop = get_option(varargin,'prop',ebsd.prop);

% allow to run again even if already EBSDsquare
ebsd = EBSD(ebsd);

% generate regular grid
dx = max(unitCell(:,1))-min(unitCell(:,1));
dy = max(unitCell(:,2))-min(unitCell(:,2));

[prop.x,prop.y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
sGrid = size(prop.x);

% if original unit cell was to much different
if numel(ebsd.unitCell) ~= 8 || 1.5*max(ebsd.unitCell(:)) < max(unitCell(:))
  
  % interpolate
  ebsd = interp(ebsd,prop.x,prop.y);

  ebsdGrid = EBSDsquare(reshape(ebsd.rotations,size(prop.x)),...
    ebsd.phaseId(:), ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',ebsd.prop,'opt',ebsd.opt);
  
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
  ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop,'opt',ebsd.opt);

end
