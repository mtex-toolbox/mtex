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

qCS = qCS.rot;

s = size(q);
q.a = q.a(:); q.b = q.b(:); q.c = q.c(:); q.d = q.d(:);
try q.i = q.i(:); end %#ok<TRYNC>

% compute distance to reference orientation
if ~isempty(q_ref)
  q_ref.a = q_ref.a(:); q_ref.b = q_ref.b(:);
  q_ref.c = q_ref.c(:); q_ref.d = q_ref.d(:);
  
  co2 = abs(quat_dot(q,q_ref));
  
else
  
  co2 = abs(q.a);

end

% may be we can skip something
minAngle = reshape(abs(qCS.angle),[],1);
minAngle = min([inf;minAngle(minAngle > 1e-3)]);
notInside = co2 < cos(minAngle/4);

% maybe we can skip everything
if any(notInside) && length(qCS) > 1

  % restrict to quaternion which are not yet it FR
  if length(q) == numel(notInside)
    q_sub = q.subSet(notInside);
  else
    q_sub = q;
  end

  % compute all distances to the fundamental regions
  if ~isempty(q_ref)
  
    % if q_ref was a list of reference rotations
    if length(q_ref) == numel(notInside)
      omegaSym  = abs(quat_dot_outer(inv(q_ref.subSet(notInside)).*q_sub,qCS));
    else
      omegaSym  = abs(quat_dot_outer(inv(q_ref).*q_sub,qCS));
    end
  
  else
    omegaSym  = abs(quat_dot_outer(q_sub,qCS));
  end

  % find symmetry elements with minimum distance
  [~,nx] = max(omegaSym,[],2);

  % project to fundamental region
  qn = times(q_sub, reshape(inv(qCS.subSet(nx)),size(q_sub)),0);

  % replace projected quaternions
  q.a(notInside) = qn.a;
  q.b(notInside) = qn.b;
  q.c(notInside) = qn.c;
  q.d(notInside) = qn.d;
end
  
% ensure correct sign
if isempty(q_ref)
  changeSign = q.a < 0;
else
  changeSign = q.a .* q_ref.a + q.b .* q_ref.b + q.c .* q_ref.c + q.d .* q_ref.d < 0;
end
q.a(changeSign) = -q.a(changeSign);
q.b(changeSign) = -q.b(changeSign);
q.c(changeSign) = -q.c(changeSign);
q.d(changeSign) = -q.d(changeSign);

q = reshape(q,s);

% some testing code
% cs = crystalSymmetry('432')
% q = quaternion.rand(100,1);
% q_ref = quaternion.rand(100,1);
% q_proj = project2FR_ref(q,quaternion(cs),q_ref);
% hist(angle(q_proj,q_ref)/degree)
