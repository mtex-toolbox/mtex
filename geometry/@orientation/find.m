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

% TODO: This does not work in case of 2 symmetries, where the space has corners.
%       Implement 2nd version the find method.
%       --> symmetries w and search again for the symmetric values of
%       w(ind), where ind = angle(w,fR) < min(d,2)

if v.CS.numSym>1 && v.SS.numSym>1
  error('The orientation.find method does not work if there is a left AND a right symmetry.')
end

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
  if check_option(varargin,'worstCaseError')
    epsilon = fR.maxAngle/2;
  else
    % expected epsilon for uniform distributed points
    V = 1/v.CS.numSym/v.SS.numSym/(1+v.antipodal);
    epsilon = (6*pi*epsilon_or_k*V/length(v))^(1/3);
    epsilon = 2*epsilon; % use slightly greater range
  end
else
  epsilon = epsilon_or_k;
end

% project v to fundamental region with some band of tolerance omega
v = v.symmetrise;
id = fR.checkInside(v,'tolerance',epsilon+1e-4);
v = v.subSet(id);
v = v.subSet(':');
[~,id] = find(id);  % x = id.*(1:10000); x(id);

% w project to fundamental region
wq = quaternion(project2FundamentalRegion(w));
vq = quaternion(v);

% find points on fundamental region
[ind,d] = find@quaternion(vq,wq,epsilon_or_k,varargin{:});

if (floor(epsilon_or_k) == epsilon_or_k)
  ind = id(ind);
  
  % determine not correctly classified points and search again for them
  nCC = max(d,[],2) > min(pi-angle(wq,fR.N) + epsilon,[],2);
  if sum(nCC)>0
    if nCC<100
      d2 = angle(v,wq(nCC)).';
      [d2,ind2] = mink(d2,epsilon_or_k,2);
    else
      [ind2,d2] = find(v,w.subSet(nCC),epsilon_or_k,'worstCaseError');
    end
    ind(nCC) = ind2;
    d(nCC) = d2;
  end

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