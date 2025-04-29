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

% Check for matching symmetries
v = orientation(v.subSet(':'));
w = orientation(w);
if v.CS~=w.CS || v.SS~=w.SS
  error('The symmetries have to coincide.')
end

% TODO: antipodal
ap={};

% decide for tolerance epsilon
if (floor(epsilon_or_k) == epsilon_or_k)
  % TODO: decide for epsilon range manually (dependent to v).
  epsilon = 10*degree;
else
  epsilon = epsilon_or_k;
end

% project v to fundamental region with some band of tolerance omega
fR = fundamentalRegion(v.CS,v.SS,ap{:});
% TODO: only symmetrise points that are in the epsilon-distance of the boundary of the fundamental region
v = v.symmetrise;
id = fR.checkInside(v,'tolerance',epsilon/2+1e-4);
v = v.subSet(id);
[~,id]=find(id);
v = v.subSet(':');

% w project to fundamental region
w = project2FundamentalRegion(w);

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