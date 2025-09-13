function isInside = checkInside(grains, xy, varargin)
% check for points or grains to be inside a big grain
%
% Syntax
%   isInside = checkInside(hostGrains, [x,y])
%   isInside = checkInside(hostGrains, inclusionGrains)
%   isInside = checkInside(hostGrains, ebsd)
%
% Input
%  hostGrains      - @grain2d
%  inclusionGrains - @grain2d
%  [x,y] - list of [x(:) y(:)] coordinates
%
% Output
%  isInside - numInclusionGrains x numHostGrains matrix
%  isInside - numEBSD x numHostGrains matrix
%  isInside - numXY x numHostGrains matrix
%
% Options
%  includeBoundary - points on the boundary are considered as inside
%  ignoreInclusions - points within inclusions belong to the host grain
%
% Description
% Note, for an EBSD pixel to be inside a grain it has to be completely
% inside the grain. Pixels at the boundary may belong to no grain.
%
% Example
%  mtexdata small
%  grains = calcGrains(ebsd('indexed'))
%  plot(grains(grains(75).checkInside(grains)))
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

ignoreInclusions = check_option(varargin,'ignoreInclusions');
includeBoundary = check_option(varargin,'includeBoundary');

if isa(xy,'grain2d') % check grains inside grains
  
  grainsIncl = xy;
    
  % we need a point that is for sure inside the grain
  % here we take an arbitrary boundary point
  xy = grainsIncl.allV(cellfun(@(x) x(1),grainsIncl.poly),:);
  
  % check whether the boundary point is strictly inside another grain
  % we need of course ignore inclusions
  isInside = grains.checkInside(xy,'ignoreInclusions');
  
  return
  
elseif isa(xy,'EBSD') % check ebsd unitcells entirely inside grain
  
  % extract unit cell
  uc = xy.unitCell.xyz;
  
  % for EBSD data the complete unitcell should be contained
  xy = xy.pos.xyz;
  
  % we have to allow boundary here
  isInside = grains.checkInside(xy+repmat(uc(1,:),size(xy,1),1),'includeBoundary');
  for i = 2:size(uc,1)
    isInside = isInside & grains.checkInside(xy+repmat(uc(i,:),size(xy,1),1),'includeBoundary');
  end
  
  return
  
end

% --- check points inside grains ---

isInside = false(size(xy,1),length(grains));

poly = grains.poly;
Vx = grains.allV.x;
Vy = grains.allV.y;
incl = grains.inclusionId;

% make sure xy is vector3d
if ~isa(xy,'vector3d'), xy = vector3d(xy); end

% use internal or external inpolygon engine?
inpolyEngine = getMTEXpref('insidepoly');

for i = 1:length(poly)

  % extract boundary
  p = poly{i};
  
  % consider only the outer boundary
  if ignoreInclusions, p = p(1:end-incl(i)); end
  
  % extract xy values of the boundary and use inpolygon
  if inpolyEngine
    [in,on] = insidepoly(xy.x,xy.y,Vx(p),Vy(p));
  else
    [in,on] = inpolygon(xy.x,xy.y,Vx(p),Vy(p));
  end
    
  if includeBoundary
    isInside(:,i) = in;
  else
    isInside(:,i) = in - on;
  end
  
end

