function ebsdNew = interp(ebsd,newPos,varargin)
% interpolate at arbitrary points (x,y)
%
% Syntax
%   ebsdNew = interp(ebsd,xNew,yNew)
%
%   ebsdNew = interp(ebsd,xNew,yNew,'method','invDist')
%
% Input
%  ebsd - @EBSDsquare
%  xNew, yNew - new x,y coordinates
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
%
% See also
%  

if ~isa(newPos,'vector3d'), newPos = vector3d(newPos,varargin{1},0); end

% new size
sizeNew = size(newPos);

% nearest neighbor interpolation first
try
  F = griddedInterpolant(ebsd.pos.x,ebsd.pos.y,ebsd.id,"nearest","none");
catch
  F = griddedInterpolant(ebsd.pos.x',ebsd.pos.y',ebsd.id',"nearest","none");
end

idNew = F(newPos.x,newPos.y);
isIndexed = ~isnan(idNew);
idNew = idNew(isIndexed);
rot = rotation.nan(sizeNew);
rot(isIndexed) = ebsd.rotations(idNew);

phaseId = ones(prod(sizeNew),1);
phaseId(isIndexed) = ebsd.phaseId(idNew);

% copy properties
prop = struct();
for fn = fieldnames(ebsd.prop).'
  
  if isnumeric(ebsd.prop.(char(fn))) || islogical(ebsd.prop.(char(fn)))
    prop.(char(fn)) = nan(sizeNew);
  else
    prop.(char(fn)) = ebsd.prop.(char(fn)).nan(sizeNew);
  end
  prop.(char(fn))(isIndexed) = ebsd.prop.(char(fn))(idNew);
end

switch nnz(sizeNew>1)
  case {0,1}
    ebsdNew = EBSD(newPos,rot,phaseId,ebsd.CSList,prop,'phaseMap',ebsd.phaseMap);
  case 2
    ebsdNew = EBSDsquare(newPos,rot,phaseId,ebsd.phaseMap,ebsd.CSList,'prop',prop,'opt',ebsd.opt);  
end

return

% more advanced interpolation methods

method = get_flag(varargin,{'invDist','nearest'},'invDist');

ix = ix(isIndexed); iy = iy(isIndexed);

switch method
  
  case 'invDist'

    delta = min(ebsd.dx,ebsd.dy)/10;
    
    % set up the interpolation matrix
    M = sparse(nnz(isIndexed),length(ebsd));
  
    % go through all first order neighbors
    M = M + updateM(floor(ix),floor(iy));
    M = M + updateM(ceil(ix),floor(iy));
    M = M + updateM(floor(ix),ceil(iy));
    M = M + updateM(ceil(ix),ceil(iy));
    
    ebsdNew.rotations(isIndexed) = M * ebsd.rotations(:);
    
  case 'nearest'
    
  case ''
    
end

  function Mdelta = updateM(ixn,iyn)
    
    doInclude = ixn > 0 & iyn > 0 & ixn <= size(ebsd,2) & iyn <= size(ebsd,1);      
    idn = ones(size(doInclude));
    idn(doInclude) = sub2ind(size(ebsd), iyn(doInclude), ixn(doInclude));
    
    dist = sqrt((xNew(isIndexed) - ebsd.pos.x(idn)).^2 + ...
      (yNew(isIndexed) - ebsd.pos.y(idn)).^2);
    
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