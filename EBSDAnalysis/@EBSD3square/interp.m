function ebsdNew = interp(ebsd, newPos, varargin)
% interpolate at arbitrary points newPos
%
% Syntax
%   ebsdNew = interp(ebsd,newPos)
%
%   ebsdNew = interp(ebsd,newPos,'method','invDist')
%
% Input
%  ebsd - @EBSD3square
%  newPos - new x,y coordinates (vector3d)
%
% Output
%  ebsdNew - @EBSD3square with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
%
% See also
%  

% ensure column vectors
xNew = newPos.x(:); yNew = newPos.y(:); zNew = newPos.z(:);
if isa(ebsd,"EBSD3"); ebsd = ebsd.gridify; end
% find nearest neighbour first
ix = 1 + (xNew-ebsd.xmin)./ebsd.dx;
iy = 1 + (yNew-ebsd.ymin)./ebsd.dy;
iz = 1 + (zNew-ebsd.zmin)./ebsd.dz;

ixn = round(ix); iyn = round(iy); izn = round(iz);

% check nearest is inside the box
isIndexed = ixn > 0 & iyn > 0 & izn > 0 & ixn <= size(ebsd,2) & iyn <= size(ebsd,1) & izn <= size(ebsd,3);

% check nearest is indexed
isIndexed(isIndexed) = ebsd.isIndexed(sub2ind(size(ebsd), iyn(isIndexed), ixn(isIndexed), izn(isIndexed)));
idNearest = sub2ind(size(ebsd), iyn(isIndexed), ixn(isIndexed), izn(isIndexed));


% nearest neighbor interpolation first
rot = rotation.nan(size(xNew));
rot(isIndexed) = ebsd.rotations(idNearest);

phaseId = ones(size(xNew));
phaseId(isIndexed) = ebsd.phaseId(idNearest);

% copy properties
prop = struct('x',xNew,'y',yNew,'z',zNew);
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end

  if isnumeric(ebsd.prop.(char(fn))) || islogical(ebsd.prop.(char(fn)))
    prop.(char(fn)) = nan(size(xNew));
  else
    prop.(char(fn)) = ebsd.prop.(char(fn)).nan(size(xNew));
  end
  prop.(char(fn))(isIndexed) = ebsd.prop.(char(fn))(idNearest);
end

rot = reshape(rot,size(newPos));
ebsdNew = EBSD3square(newPos,rot,phaseId,ebsd.CSList,prop,[ebsd.dx,ebsd.dy,ebsd.dz],'unitCell',ebsd.unitCell);
ebsdNew.phaseMap = ebsd.phaseMap;
ebsdNew.phaseId = phaseId(:);
ebsdNew.CSList = ebsd.CSList;

% more advanced interpolation methods

method = get_flag(varargin,{'invDist','nearest'},'invDist');

ix = ix(isIndexed); iy = iy(isIndexed); iz = iz(isIndexed);

switch method
  
  case 'invDist'

    delta = min([ebsd.dx,ebsd.dy,ebsd.dz])/10;
    
    % set up the interpolation matrix
    M = sparse(nnz(isIndexed),length(ebsd));
  
    % go through all first order neighbours
    M = M + updateM(floor(ix),floor(iy),floor(iz));
    M = M + updateM(ceil(ix),floor(iy),floor(iz));
    M = M + updateM(floor(ix),ceil(iy),floor(iz));
    M = M + updateM(ceil(ix),ceil(iy),floor(iz));
    M = M + updateM(floor(ix),floor(iy),ceil(iz));
    M = M + updateM(ceil(ix),floor(iy),ceil(iz));
    M = M + updateM(floor(ix),ceil(iy),ceil(iz));
    M = M + updateM(ceil(ix),ceil(iy),ceil(iz));
    
    ebsdNew.rotations(isIndexed) = M * ebsd.rotations(:);
    
  case 'nearest'
    
  case ''
    
end

    function Mdelta = updateM(ixn,iyn,izn)
    
    doInclude = ixn > 0 & iyn > 0 & izn > 0 & ...
                ixn <= size(ebsd,2) & iyn <= size(ebsd,1) & izn <= size(ebsd,3);      
    idn = ones(size(doInclude));
    idn(doInclude) = sub2ind(size(ebsd), iyn(doInclude), ixn(doInclude), izn(doInclude));
    
    dist = sqrt((xNew(isIndexed) - ebsd.prop.x(idn)).^2 + ...
      (yNew(isIndexed) - ebsd.prop.y(idn)).^2 + ...
      (zNew(isIndexed) - ebsd.prop.z(idn)).^2);
    
    weights = 1./ (delta + dist);
    if isfield(prop,'grainId')
      doInclude = doInclude & (ebsd.prop.grainId(idn) == prop.grainId(isIndexed)) & ...
        angle(ebsd.rotations(idn),rot(isIndexed)) < 2.5*degree;
    else
      doInclude = doInclude & (ebsd.phaseId(idn) == phaseId(isIndexed)) & ...
        angle(ebsd.rotations(idn),rot(isIndexed)) < 5*degree;
    end
    
    Mdelta = sparse(1:nnz(isIndexed),idn,doInclude .* weights,...
      nnz(isIndexed),length(ebsd));
  end

end