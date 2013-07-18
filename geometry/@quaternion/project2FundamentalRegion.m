function [q,omega] = project2FundamentalRegion(q,CS,SS,q_ref)
% projects quaternions to a fundamental region
%
%% Input
%  q      - @quaternion
%  CS, SS - crystal / specimen @symmetry
%  q_ref  - one reference @quaternion in or size(q)
%
%% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

%% get quaternions

if nargin < 4,
  q_ref = idquaternion;
else
  q_ref = quaternion(q_ref);
end
q = quaternion(q);

% may be we can skip something
omega = abs(dot(q,q_ref));
ind   = omega < cos(getMaxAngle(CS,SS)/2);

if ~any(ind),
  omega = 2*acos(min(1,omega));
  return;
end

if numel(q) == numel(ind)
  qsub = subsref(q,ind);
else
  qsub = q;
end
if numel(q_ref) == numel(ind)
  q_ref = subsref(q_ref,ind);
end

% symetry elements
if nargin < 3 || numel(SS) <= 1
  qCS = quaternion(CS);
else
  qCS = reshape(unique(CS*inverse(SS)),[],1);  
end

% compute all distances to the fundamental regions
omegaSym = abs(dot_outer(inverse(qsub).*q_ref,qCS));

% find fundamental region
[omega(ind),ix] = max(omegaSym,[],2);

% project to fundamental region
q = subsasgn(q,ind,qsub .* subsref(qCS,ix));

% compute angle
omega = 2*acos(min(1,omega));

