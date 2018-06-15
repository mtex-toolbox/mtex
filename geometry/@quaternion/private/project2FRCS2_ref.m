function [q,ics1,ics2] = project2FRCS2_ref(q,CS1,CS2,q_ref)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS1,CS2,q_ref)  % misorientation to FR
%   around q_ref
%
% Input
%  q        - list of @quaternion
%  q_ref    - a single reference @quaternion
%  CS1, CS2 - crystal @symmetry
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

% project to fundamental region
% note: d(CS2 * q * CS1, q_ref) = d(q, inv(CS2) * q_ref * inv(CS1))
[qs,m,~] = unique(inv(quaternion(CS2)) * q_ref * inv(quaternion(CS1)),'antipodal'); %#ok<MINV>
[ics2,ics1] = ind2sub([length(CS2),length(CS1)],m);

% take the minimum distances to all symmetric equivalent orientations
[~,i12] = max(abs(dot_outer(q,qs)),[],2);
ics1 = ics1(i12);
ics2 = ics2(i12);

% project to fundamental region
q = reshape(CS2.subSet(ics2),[],1) .* reshape(q,[],1) .* reshape(CS1.subSet(ics1),[],1);

% some testing code
% cs1 = crystalSymmetry('432')
% cs2 = crystalSymmetry('32')
% q_ref = quaternion.rand(1,1);
% q = quaternion.rand(100,1);
% q_proj = project2FRCS2_ref(q,cs1,cs2,q_ref);
% hist((angle(q_proj,q_ref) )/degree)
