function q = project2FRCS2(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS1,CS2)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - @symmetry
%
% Output
%  q     - @quaternion
%

% TODOs:
% (1) symmetry/factor is slow 
% (2) disjoint(CS1,CS2) is very slow
% (3) vector3d/project2fundamentalSector is slow

% factorize symmetries
% CS1 -> r, CS2 -> l
% d(l * q * r * d, id) = d(q,inv(l) * id * inv(rd)) = d(q,inv(rd*l))
[r,d,l] = factor(CS1.properGroup,CS2.properGroup);
rd = r * d;
qs = inv(rd * l);
[i,j] = ind2sub([numel(rd),numel(l)],1:length(qs));

% may be we can skip something
minAngle = reshape(abs(qs.angle),[],1);
minAngle = min([inf;minAngle(minAngle > 1e-3)]);
notInside = abs(q.a) < cos(minAngle/4); % angle(q) > minAngle/2

% restrict to quaternion which are not yet it FR
q_sub = quaternion(q.a(notInside),q.b(notInside),q.c(notInside),q.d(notInside));

% compute all distances to the symmetric equivalent orientations
% and take the minimum
[~,nx] = max(abs(dot_outer(q_sub,qs)),[],2);

% project to fundamental region
% note: d(q,l*d*r) = d(inv(l)*q*inv(dr))
qn = reshape(l.subSet(j(nx)),[],1) ...
  .* reshape(q_sub,[],1) .* reshape(rd.subSet(i(nx)),[],1);

% replace projected quaternions
q.a(notInside) = qn.a;
q.b(notInside) = qn.b;
q.c(notInside) = qn.c;
q.d(notInside) = qn.d;

% ensure q.a is non-negative
sgn = sign(1-2*(q.a < 0));
q.a = q.a .* sgn; q.b = q.b .* sgn; q.c = q.c .* sgn; q.d = q.d .* sgn;

% next we have to project the rotational axis into the fundamental sector
% of the disjoint symmetry
axis = vector3d(q.b,q.c,q.d);
axis = project2FundamentalRegion(axis,...
  properGroup(disjoint(CS1,CS2)),varargin{:}); % here we need a speed up
q.b = axis.x; q.c = axis.y; q.d = axis.z;

% old code for the above
%axis = project2FundamentalRegion(q.axis, properGroup(disjoint(CS1,CS2)),varargin{:});
%q = axis2quat(axis,q.angle);

% some testing code
% cs1 = crystalSymmetry('432')
% cs2 = crystalSymmetry('32')
% q = quaternion.rand(100,1);
% q_proj = project2FRCS2(q,cs1,cs2)
% hist(q_proj.angle./degree)
% scatter(q,'markerColor','b')
% hold on
% scatter(q_proj,'markercolor','r')
% oR = fundamentalRegion(cs1,cs2)
% plot(oR)
% all(oR.checkInside(q_proj))
