function S3G = symmetrise(S3G,varargin)
% symmetrcially equivalent orientations
%
%% Input
%  S3G - @SO3Grid
%
%% Output
%  S3G - @SO3Grid
%
%% See also

cs = S3G(1).CS; ss = S3G(1).SS;
S3G = SO3Grid(symmetrise(quaternion(S3G),cs,ss),cs,ss);

