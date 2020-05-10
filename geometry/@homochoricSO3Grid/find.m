function [id,dist] = find(S3G,ori,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax
%   % find the closes point
%   [ind,dist] = find(SO3G,ori)
%
%   % find points with a radius
%   [ind,dist] = find(SO3G,ori,radius)
%
%   % find cube corners
%   cubeInd = find(SO3G,ori,'cube')
%
% Input
%  SO3G   - @homochoricSO3Grid
%  ori    - @orientation
%  radius - double
%
% Output
%  ind  - index of the closes grid point
%  cubeInd - Nx8 list of indeces of the cube corners containing ori
%  dist - misorientation angle
%

ori = project2FundamentalRegion(ori,S3G.CS,S3G.SS);

% translate input (ori) into cubochoric coordinates
qin = [ori.a(:),ori.b(:),ori.c(:),ori.d(:)];
xyz = quat2cube(qin);

% each edge of the cube is splitted into N intervals -> N+1 points
% each interval has the length hres
N = round(2 * pi / S3G.res);
hres = S3G.res / pi^(1/3) / 2;

if nargin == 2 % closest point
  
  % calculate grid index along each axis of the cube
  % let the grid have N+1 points along each axis
  % then xyz/hres takes values -N/2,-N/2+1,...,(0),...,N/2-1,N/2
  % 0 is included iff N is even
  % so xyz/hres+N/2+1 takes values 1,...,N+1
  sub  = round(xyz / hres + N/2 + 1);
  
  % take care about boundary effect
  
  
  % calculate grid-index (row in XYZ) of S3G
  id   = sub2ind(S3G,sub(:,1),sub(:,2),sub(:,3));
  
  % calculate the euclidean distance
  if nargout > 1, dist = dot(S3G.subSet(id),ori); end
    
elseif ischar(varargin{1}) % cube c
  
  % calculate grid position along each axis
  ix = floor(xyz(:,1)/hres + N/2 + 1);
  iy = floor(xyz(:,2)/hres + N/2 + 1);
  iz = floor(xyz(:,3)/hres + N/2 + 1);
  
  % lower the coordinates of points that lie on the surface
  if (max(ix)>N), ix = N; end
  if (max(iy)>N), iy = N; end
  if (max(iz)>N), iz = N; end
  
  cx = [0 0 0 0 1 1 1 1];
  cy = [0 0 1 1 0 0 1 1];
  cz = [0 1 0 1 0 1 0 1];
  
  % take care about boundary effect

  id = sub2ind(S3G, ix(:) + cx, iy(:) + cy, iz(:) + cz);
  
else % neighborhood
  
end

end