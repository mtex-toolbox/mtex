function [ind,d] = find(v,w,epsilon_or_k,varargin)
% return index of all points in an epsilon neighborhood of a vector
%
% Syntax
%   ind = find(v,w)         % find closest point out of v to w
%   ind = find(v,w,epsilon) % find all points out of v in an epsilon neighborhood of w
%   ind = find(v,w,k)       % find k nearest points out of v to w
%
% Input
%  v, w         - @vector3d
%  epsilon_or_k - epsilon or k (see below), depending on what the user wants
%  epsilon      - double
%  k            - int32
%
% Options
%  antipodal    - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  ind          - int32 array for k nearest neighbors,
%               - sparse logical incidence matrix for region search
%  d            - double array for k nearest neighbors, 
%               - sparse double array for region search (0 whenever ind is 0)
%

if nargin==2, epsilon_or_k=1; end

% TODO: Implement 2nd version the find method.
%         - vp = project2FundamentalRegion(v);
%         - find neighbors for all points.
%         - if     distance of v to boundary < inner distance / eps  shift FR and do again for this points 
%

% TODO: Do not work for some symmetries
% Bug in project2FundamentalRegion

% Check for matching symmetries
v = orientation(v.subSet(':'));
w = orientation(w);
if v.CS~=w.CS || v.SS~=w.SS
  error('The symmetries have to coincide.')
end

% compute fundamental Region
ap ={};
if v.antipodal
  ap={'antipodal'};
end
fR = fundamentalRegion(v.CS,v.SS,ap{:});

% decide for tolerance epsilon
if (floor(epsilon_or_k) == epsilon_or_k)
  % worst case
  epsilon = fR.maxAngle/2;
  % expected epsilon for uniform distributed points
  % V = 1/v.CS.numSym/v.SS.numSym/(1+v.antipodal);
  % epsilon = (6*pi*epsilon_or_k*V/length(v))^(1/3);
  % epsilon = 1.3*epsilon % use slightly greater range
else
  epsilon = epsilon_or_k;
end

% project v to fundamental region with some band of tolerance omega
v = v.symmetrise;
id = fR.checkInside(v,'tolerance',epsilon/2+1e-4);
v = v.subSet(id);
v = v.subSet(':');
[~,id] = find(id);  % x = id.*(1:10000); x(id);

% w project to fundamental region
w = quaternion(project2FundamentalRegion(w));
v = quaternion(v);

% find points on fundamental region
[ind,d] = find@quaternion(v,w,epsilon_or_k,varargin{:});

% TODO: write cosistent Code
if (floor(epsilon_or_k) == epsilon_or_k)
  ind = id(ind);
else
  S = sparse(1:length(id), id, true, length(id), max(id));
  ind = ind * S;
  d = d*S;
end

end

function test

% construct data
cs = crystalSymmetry('321');
ss = crystalSymmetry('222');
ap = {};

omega = 1*degree;
K=4;

rng(0)
v = orientation.rand(1e5,cs,ss);
w = orientation.rand(10,cs,ss);


[ind,d] = find(v,w,omega)


% compute with distances
d2 = angle(w,v.');

ind2 = sparse(d2 < omega)
d2 = d2(ind2)

[d3,ind3] = mink(d2,K,2) 

end