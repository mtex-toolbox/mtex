function [q,omega] = project2FundamentalRegion(q,CS1,CS2,q_ref)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS)       % to FR around idquaternion
%   project2FundamentalRegion(q,CS,q_ref) % to FR around reference rotation
%   project2FundamentalRegion(q,CS1,CS2,q_ref)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - reference @quaternion single or size(q) == size(q_ref)
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

% get quaternions
qCS1 = unique(quaternion(CS1),'antipodal');

if nargin == 2, 
  q_ref = idquaternion;
  qCS2  = idquaternion;
elseif nargin == 3
  if isa(CS2,'symmetry')
    qCS2  = unique(quaternion(CS2),'antipodal'); 
    q_ref = idquaternion;
  else
    qCS2  = idquaternion;
    q_ref = quaternion(CS2);
  end
else
  qCS2  = unique(quaternion(CS2),'antipodal');
  q_ref = quaternion(q_ref);
end

q = reshape(q,[],1);

% compute distance to reference orientation
omega = abs(dot(quaternion(q),q_ref));

% may be we can skip something
ind   = omega < cos(getMaxAngle(CS1,qCS2)/2);
if ~any(ind) || length(qCS1) == 1
  omega = 2*acos(min(1,omega));
  return
end

% restrict to quaternion which are not yet it FR
if length(q) == numel(ind)
  q_sub = quaternion(q.subSet(ind));
else
  q_sub = quaternion(q);
end

% if q_ref was a list of reference rotations
if length(q_ref) == numel(ind), q_ref = q_ref.subSet(ind); end

% use that angle( CS2*q*CS1 ) =  angle( q * CS1 * inv(CS2) )
[uCS,m,~] = unique(qCS1*inv(qCS2),'antipodal'); %#ok<MINV>
[i,j]     = ind2sub([length(qCS1),length(qCS2)],m);

% compute all distances to the fundamental regions
omegaSym  = abs(dot_outer(inv(q_sub).*q_ref,uCS));

% find symmetry elements projecting to fundamental region
[omega(ind),nx] = max(omegaSym,[],2);

% project to fundamental region
qn = reshape(inv(qCS2.subSet(j(nx))),[],1) ...
  .* reshape(q_sub,[],1) .* reshape(qCS1.subSet(i(nx)),[],1);

% replace projected quaternions
q.a(ind) = qn.a;
q.b(ind) = qn.b;
q.c(ind) = qn.c;
q.d(ind) = qn.d;

% compute angle
omega = 2*acos(min(1,omega));

