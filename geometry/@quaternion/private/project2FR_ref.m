function q = project2FR_ref(q,qCS,q_ref)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS,q_ref) % to FR around reference rotation
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

q = reshape(q,[],1);
q_ref = reshape(q_ref,[],1);

% compute distance to reference orientation
co2 = abs(dot(q,q_ref));

% may be we can skip something
minAngle = reshape(abs(qCS.angle),[],1);
minAngle = min([inf;minAngle(minAngle > 1e-3)]);
notInside = 2 * acos(co2) > minAngle/2;

% maybe we can skip everything
if ~any(notInside) || length(qCS) == 1, return; end

% restrict to quaternion which are not yet it FR
if length(q) == numel(notInside)
  q_sub = q.subSet(notInside); 
else
  q_sub = q;
end

% if q_ref was a list of reference rotations
if length(q_ref) == numel(notInside), q_ref = q_ref.subSet(notInside); end

% compute all distances to the fundamental regions
omegaSym  = abs(dot_outer(inv(q_ref).*q_sub,qCS));

% find symmetry elements with minimum distance
[~,nx] = max(omegaSym,[],2);

% project to fundamental region
qn = reshape(q_sub,[],1) .* reshape(inv(qCS.subSet(nx)),[],1);

% replace projected quaternions
q.a(notInside) = qn.a;
q.b(notInside) = qn.b;
q.c(notInside) = qn.c;
q.d(notInside) = qn.d;

% some testing code
% cs = crystalSymmetry('432')
% q = quaternion.rand(100,1);
% q_ref = quaternion.rand(100,1);
% q_proj = project2FR_ref(q,quaternion(cs),q_ref);
% hist(angle(q_proj,q_ref)/degree)

