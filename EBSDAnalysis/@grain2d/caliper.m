function c = caliper(grains,varargin)
% Calliper (Feret diameter) of a grain in measurement units, the projection
% length normal to it and its direction/trend.
%
% Syntax
%
%   c = caliper(grains,omega)
%   cV = caliper(grains,'shortest')
%   cV = caliper(grains,'longest')
%
% Input:
%  grains   - @grain2d
%
% Output:
%  c     - caliper at angle |omega|
%  cV    - @vector3d, norm(cV) is the length
%
% Options:
%  shortest  - shortest caliper
%  longest   - longest caliper = diameter of the grain
%              

V = grains.V;

if nargin > 1 && isnumeric(varargin{1})

  omega = varargin{1}(:).';
  proj = V * [cos(omega);sin(omega)];
  
  if length(omega)>1
    c = cellfun(@(id) max(proj(id,:) - min(proj(id,:)),[],1),grains.poly,'UniformOutput',false);
    c = vertcat(c{:});
  else
    c = cellfun(@(id) max(proj(id,:) - min(proj(id,:)),[],1),grains.poly);
  end
  
  return
    
elseif nargin > 1 && strcmpi(varargin{1},'short_slow')
   
  fak = -1;
    
  c = -fak * inf(size(grains));
  omega = zeros(size(grains));
  
  % loop through all angles
  for o = linspace(0,pi,20)
  
    proj = V * [cos(o);sin(o)];
    cTmp = cellfun(@(id) max(proj(id,:) - min(proj(id,:)),[],1),grains.poly);
    
    isBetter = fak * (cTmp - c) > 0;
    omega(isBetter) = o;
    c(isBetter) = cTmp(isBetter);    
    
  end
  
  c = sqrt(c);
  
elseif nargin > 1 && check_option(varargin,{'shortest','shortestPerp'})
  
  poly = grains.poly;
  scaling = 10000 ;
  V = round(scaling * grains.V);
  c = nan(size(grains));
  omega = nan(size(grains));

  
  for ig = 1:length(grains)
    
    Vg = V(poly{ig},:);
  
    % Convex Hull
    k = convhull(Vg,'Simplify',true);
    VgHull = Vg(k,:);
    
    % Finding out the antipodal pairs
    apPairs = antipodalPairs(VgHull);
        
    [c(ig), omega(ig)] = minCaliper(VgHull,apPairs);
  
    if check_option(varargin,'shortestPerp')
      omega(ig) = omega(ig) + pi/2;
      c(ig) = scaling * projectionLength(Vg, omega(ig));
    end
    
  end
  
  c = c / scaling;

else
  
  poly = grains.poly;
  V = grains.V;
  c = nan(size(grains));
  
  for ig = 1:length(grains)
    
    Vg = V(poly{ig},:);
    
    % reduce to convex hull for large grains
    if length(Vg) > 100, Vg = Vg(convhull(Vg,'Simplify',true),:); end
    
    % find the maximum distance between any vertices
    dist = (Vg(:,1) - Vg(:,1).').^2 + (Vg(:,2) - Vg(:,2).').^2;
    [c(ig),id] = max(dist(:));
    
    % find corresponding vertices
    [i1,i2] = ind2sub(size(dist),id);
    
    % get the angle with x-axis
    omega(ig) = atan2(Vg(i1,2) - Vg(i2,2), Vg(i1,1) - Vg(i2,1));
  
  end
  
  c = sqrt(c);
  
end

% convert to vector3d
c = c(:) .* vector3d.byPolar(pi/2,omega(:),'antipodal');

end

function [minDiameter, minAngle] = minCaliper(hull_corners, apPairs)
% Calculate minimum Feret Features - MinDiameter, MinAngle, MinCoordinates

N = size(apPairs,1);
P = apPairs(:,1);
Q = apPairs(:,2);
minDiameter = Inf;
 
trianglePoints = [];
 
for k = 1:N
  if k == N
    k1 = 1;
  else
    k1 = k+1;
  end
  
  pt1 = [];
  pt2 = [];
  pt3 = [];
  
  if (P(k) ~= P(k1)) && (Q(k) == Q(k1))
    pt1 = hull_corners(P(k),:);
    pt2 = hull_corners(P(k1),:);
    pt3 = hull_corners(Q(k),:);
    
  elseif (P(k) == P(k1)) && (Q(k) ~= Q(k1))
    pt1 = hull_corners(Q(k),:);
    pt2 = hull_corners(Q(k1),:);
    pt3 = hull_corners(P(k),:);
  end
  
  if ~isempty(pt1)
    % Points pt1, pt2, and pt3 form a possible minimum Feret diameter.
    % Points pt1 and pt2 form an edge parallel to caliper direction.
    % The Feret diameter orthogonal to the pt1-pt2 edge is the height
    % of the triangle with base pt1-pt2.
    area = ((pt2(1) - pt1(1)) * (pt3(2) - pt1(2)) -(pt2(2) - pt1(2)) * (pt3(1) - pt1(1)) ) / 2;
    d_k =  2 * abs(area) / norm(pt1 - pt2);
    
    if d_k < minDiameter
      minDiameter = d_k;
      trianglePoints = [pt1; pt2; pt3];
    end
  end
end

e = trianglePoints(2,:) - trianglePoints(1,:);
thetad = atan2d(e(2),e(1));
minAngle = (mod(thetad + 180 + 90,360) - 180)*degree;

end

function pq = antipodalPairs(S)
% For a convex polygon, an antipodal pair of vertices is one where you
% can draw distinct lines of support through each vertex such that the
% lines of support are parallel.
% A line of support is a line that goes through a polygon vertex such
% that the interior of the polygon lies entirely on one side of the line.

% This function uses the "ANTIPODAL PAIRS" algorithm, Preparata and
% Shamos, Computational Geometry: An Introduction, Springer-Verlag, 1985,
% p. 174.

n = size(S,1);

if isequal(S(1,:),S(n,:))
  % The input polygon is closed. Remove the duplicate vertex from the
  % end.
  S(n,:) = [];
  n = n - 1;
end

% area calculates the area of the triangle enclosed by S(i,:), S(j,:) &
% S(k,:)
area = @(i,j,k) signedTriangleArea(S(i,:),S(j,:),S(k,:));
% next(p) returns the index of the next vertex of S.
next = @(i) mod(i,n) + 1; p = n;
p0 = next(p);
q = next(p);

% The list of antipodal vertices will be stored in the vectors pp and qq.
% Initialise with number of maximum possible combinations
pp = zeros(n*n,1);
qq = zeros(n*n,1);

while (area(p,next(p),next(q)) > area(p,next(p),q))
  q = next(q);
end
q0 = q;
i = 1;
while (q ~= p0)
  p = next(p);
  % (p,q) is an antipodal pair.
  pp(i) = p;
  qq(i) = q;
  i = i+1;
  
  while (area(p,next(p),next(q)) > area(p,next(p),q))
    q = next(q);
    if ~isequal([p q],[q0,p0])
      pp(i) = p;
      qq(i) = q;
      i = i+1;
    else
      break
    end
  end
  % Check for parallel edges.
  if (area(p,next(p),next(q)) == area(p,next(p),q))
    if ~isequal([p q],[q0 n])
      % (p,next(q)) is an antipodal pair.
      pp(i) = p;
      qq(i) = next(q);
      i = i +1;
    else
      break
    end
  end
end
% Remove unused part of the array pp & qq
pp = pp(pp~=0);
qq = qq(qq~=0);
% pq are the antipodal pairs
pq = [pp qq];
end

function area = signedTriangleArea(A,B,C)
% Function to calculate the area of triangle formed by A, B & C as vertices

area = ( (B(1) - A(1)) * (C(2) - A(2)) - ...
  (B(2) - A(2)) * (C(1) - A(1)) ) / 2;
end
