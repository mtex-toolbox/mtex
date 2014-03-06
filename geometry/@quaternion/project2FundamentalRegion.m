function [q,omega] = project2FundamentalRegion(q,CS1,q_ref)
% projects quaternions to a fundamental region
%
%% Syntax
% project2FundamentalRegion(q,CS)       - to FR around idquaternion
% project2FundamentalRegion(q,CS,q_ref) - to FR around reference rotation
% project2FundamentalRegion(q,CS1,CS2)  - misorientation to FR around id
%
%% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - one reference @quaternion or in size(q) or second crystal @symmetry
%
%% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

%% get quaternions

q    = quaternion(q);
qCS1 = quaternion(CS1);

if nargin < 3, q_ref = idquaternion; end
if isa(q_ref,'symmetry')
  qCS2  = quaternion(q_ref);  % second crystal symmetry
  q_ref = idquaternion;       % reference rotation must be identity
else
  qCS2  = idquaternion;
  q_ref = quaternion(q_ref);
end

% may be we can skip something
omega = abs(dot(q,q_ref));
ind   = omega < cos(getMaxAngle(CS1,qCS2)/2);
if ~any(ind)
  omega = 2*acos(min(1,omega));
  return
end

if numel(q) == numel(ind)
  q_sub = subsref(q,ind);
else
  q_sub = q;
end
if numel(q_ref) == numel(ind)
  q_ref = subsref(q_ref,ind);
end

[uCS,m,n] = unique(qCS1*inverse(qCS2),'antipodal');
[i,j]     = ind2sub([numel(qCS1),numel(qCS2)],m);

% compute all distances to the fundamental regions
omegaSym  = abs(dot_outer(inverse(q_sub).*q_ref,uCS));

% find symmetry elements projecting to fundamental region
[omega(ind),nx] = max(omegaSym,[],2);

% project to fundamental region
q = subsasgn(q,ind,inverse(subsref(qCS2,j(nx))).*q_sub.*subsref(qCS1,i(nx)));

% compute angle
omega = 2*acos(min(1,omega));

