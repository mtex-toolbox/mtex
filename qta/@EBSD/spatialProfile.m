function varargout = spatialProfile(ebsd,lineX,varargin)
% selects property values on a given line segment
% 
% Syntax
%   % plots a profile of property bc
%   spatialProfile(ebsd,lineX,'property','bc') 
%
%   % returns a sorted list p, where p a property and a distance |dist| to begin of line segment 
%   [p,dist] = spatialProfile(ebsd,lineX,'property','bc')
%
% Input
%  ebsd  - @EBSD
%  lineX - list of spatial coordinates |[x(:) y(:)]| of if 3d |[x(:) y(:) z(:)]|, 
%    where $x_i,x_{i+1}$ defines a line segment
% Options
%  property - by default orientation, otherwise a property field.
%
% Example
%
%   plot(ebsd)
%   lineX = ginput(2)
%   spatialProfile(ebsd,lineX,'property','mad')
%

if isa(ebsd,'GrainSet'), ebsd = get(ebsd,'EBSD');end

if all(isfield(ebsd.prop,{'x','y','z'}))
  x_D = [ebsd.prop.x,ebsd.prop.y,ebsd.prop.z];
elseif all(isfield(ebsd.prop,{'x','y'}))
  x_D = [ebsd.prop.x,ebsd.prop.y];
else
  error('mtex:SpatialProfile','no Spatial Data!');
end


prop = get_option(varargin,'property','orientation');
propVal = get(ebsd,prop);

radius = unitCellDiameter(ebsd.unitCell)/2;

% work with homogenous coordinates
x_D(:,end+1) = 1;

dist = 0;
p = propVal(1);

dim = size(lineX,2);
for k=1:size(lineX,1)-1
  % setup transformation matrix
  % line from A to B
  dX = lineX(k+1,:)-lineX(k,:);
  
  [s,b,D] = svd(dX./norm(dX));
  
  % if s is negative, shift into B, else shift into A
  D(dim+1,dim+1) = 1;
  D(:,end) =  [-lineX(k+double(s<0),:) 1] * D';
  
  % homogen linear tranformation�
  x_DX = x_D*D';
  
  sel =  sqrt(sum(x_DX(:,2:end-1).^2,2)) <= radius &  ... distance to line
    0 <= x_DX(:,1) & x_DX(:,1) <= norm(dX); % length of line segment
  
  % append to the list
  t = x_DX(sel,1);
  
  % if we start with the B, reverse the distance
  if double(s<0), t = max(t)-t; end
  
  [t ndx] = sort(t);
  ptemp = propVal(sel);
  p = [p; ptemp(ndx)];
  dist = [dist; dist(end)+t];
  
end

p(1) = []; dist(1) = [];

if nargout > 0
  
  varargout{1} = p;
  varargout{2} = dist;
  
else
  
  if isa(p,'quaternion')
    p = angle(p,p(1))/degree;
    prop = mtexdegchar;
  else
    p = p - p(1);
  end
  
  optiondraw(plot(dist,p),varargin{:});
  ylabel(['\Delta in ' prop])
  xlabel('distance')
  
end


% ----------------------------------------------------------------
function d = unitCellDiameter(unitCell)


diffVg = bsxfun(@minus,...
  reshape(unitCell,[size(unitCell,1),1,size(unitCell,2)]),...
  reshape(unitCell,[1,size(unitCell)]));
diffVg = sum(diffVg.^2,3);
d  = sqrt(max(diffVg(:)));

