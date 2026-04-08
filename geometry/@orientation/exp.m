function ori = exp(ori,v,varargin)
% exponential function
%
% Syntax
%   ori_2 = exp(ori_1,v)
%   ori_2 = exp(ori_1,S)
%
% Input
%  ori_1 - @orientation
%  v     - @SO3TangentVector, @spinTensor
%
% Output
%  ori_2 - @orientation rotate ori_1 about axis v with angle norm(v) 
%
% See also
% vector3d/exp spinTensor/exp SO3TangentVector/exp Miller/exp
%

ori = exp(v,ori,varargin{:});