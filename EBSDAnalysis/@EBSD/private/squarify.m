function [ebsdGrid,ind] = squarify(ebsd,varargin)

uC = ebsd.unitCell;
omega = angle(uC,vector3d(-1,-1,0),zvector);
[~,a] = sort(omega);
uC = uC(a);

[pos,ind] = calcMesh(ebsd.pos,uC,varargin{:});

sGrid = size(pos);

% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(ind) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(ind) = ebsd.rotations.a;
b(ind) = ebsd.rotations.b;
c(ind) = ebsd.rotations.c;
d(ind) = ebsd.rotations.d;

% update all other properties
prop = ebsd.prop;
for fn = fieldnames(ebsd.prop).'
  if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
    prop.(char(fn)) = nan(sGrid);
  else
    prop.(char(fn)) = prop.(char(fn)).nan(sGrid);
  end
  prop.(char(fn))(ind) = ebsd.prop.(char(fn));
end

% store old id
prop.oldId = nan(sGrid);
prop.oldId(ind) = ebsd.id;

ebsdGrid = EBSDsquare(pos,rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,'prop',prop,'opt',ebsd.opt,'unitCell',uC);

end
