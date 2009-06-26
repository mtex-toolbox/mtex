function [q,omega] = getFundamentalRegion(S3G,q_ref)
% projects orientations to a fundamental region
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  CENTER - reference orientation
%
%% Output
%  q     - @quaternion
%  omega - rotational angle
% 
% q_ref = get_option(varargin,'center',idquaternion);
% 
% q = symmetriceQuat(S3G(1).CS,[],quaternion(S3G));
% omega = 2*acos(abs(dot(q,q_ref)));
% 
% [omega,q] = selectMinbyRow(omega,q);

if nargin == 1, q_ref = idquaternion;end
q = quaternion(S3G);

% may be we can skip something
omega = 2*acos(abs(dot(q,q_ref)));
ind = omega > 20*degree;

if ~any(ind), return;end

qSym = symmetriceQuat(S3G(1).CS,[],q(ind));
omegaSym = 2*acos(abs(dot(qSym,q_ref)));

[omega(ind),q(ind)] = selectMinbyRow(omegaSym,qSym);
