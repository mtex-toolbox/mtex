function [SO3F,resvec] = interpolate(ori,values,varargin)
% compute an ODF by interpolating orientations and weights
%
% Syntax
%   odf = SO3Fun.interpolate(ori,values)
%
% Input
%  ori - @orientation
%  values - double
%
% Flags
%  lsqr      - least squares (MATLAB)
%  lsqnonneg - non negative least squares (MATLAB, fast)
%  lsqlin    - interior point non negative least squares (optimization toolbox, slow)
%  nnls      - non negative least squares (W.Whiten)
% 
% Output
%  SO3F - @SO3FunRBF
%
% See also
% SO3FunRBF.interpolate

[SO3F,resvec] = SO3FunRBF.interpolate(ori,values,varargin{:});
