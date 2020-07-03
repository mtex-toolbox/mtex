function q = project2FRCS2(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS1,CS2)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%
% Output
%  q     - @quaternion

q = quaternion(q);

% get quaternions
[l,d,r] = factor(CS1,CS2);
dr= d * r;
qs = l * dr;
[i,j] = ind2sub([length(l),length(dr)],1:length(qs));

% may be we can skip something
minAngle = reshape(abs(qs.angle),[],1);
minAngle = min([inf;minAngle(minAngle > 1e-3)]);
notInside = abs(q.a) < cos(minAngle/4); % angle(q) > minAngle/2

% restrict to quaternion which are not yet it FR
q_sub = q.subSet(notInside);

% compute all distances to the symmetric equivalent orientations
% and take the minimum
[~,nx] = max(abs(dot_outer(q_sub,qs)),[],2);

% project to fundamental region
% note: d(q,l*d*r) = d(inv(l)*q*inv(dr))
qn = reshape(inv(l.subSet(i(nx))),[],1) ...
  .* reshape(q_sub,[],1) .* reshape(inv(dr.subSet(j(nx))),[],1);

% replace projected quaternions
q.a(notInside) = qn.a;
q.b(notInside) = qn.b;
q.c(notInside) = qn.c;
q.d(notInside) = qn.d;

% next we have to project the rotational axis into the fundamental sector
% the coresponds to the disjoint symmetry
axis = project2FundamentalRegion(q.axis,...
  properGroup(disjoint(CS1,CS2)),varargin{:});
q = axis2quat(axis,q.angle);

% some testing code
% cs1 = crystalSymmetry('432')
% cs2 = crystalSymmetry('32')
% q = quaternion.rand(100,1);
% q_proj = project2FRCS2(q,cs1,cs2)
% hist(q_proj.angle./degree)
% scatter(q,'markercolor','b')
% hold on
% scatter(q_proj,'markercolor','r')
% oR = fundamentalRegion(cs1,cs2)
% plot(oR)
% all(oR.checkInside(q_proj))
