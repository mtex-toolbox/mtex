function h = quat2ipdf(S3G,varargin)

% get specimen direction
r = get_option(varargin,'r',xvector,'vector3d');

% compute crystal directions
h = inverse(quaternion(S3G)) .* r;
