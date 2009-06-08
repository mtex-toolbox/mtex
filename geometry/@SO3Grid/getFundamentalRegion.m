function [q,omega] = getFundamentalRegion(S3G,varargin)
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

q_ref = get_option(varargin,'center',idquaternion);

q = symmetriceQuat(S3G(1).CS,[],quaternion(S3G));
omega = rotangle(q * inverse(q_ref));

[omega,q] = selectMinbyRow(omega,q);
