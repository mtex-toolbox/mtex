function S3G = symmetrice(S3G,varargin)
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
S3G = SO3Grid(symmetriceQuat(cs,ss,quaternion(S3G)),cs,ss);

