function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution with a function or a kernel on SO(3)
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
%   SO3F = conv(SO3F1,psi)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  psi  - convolution @SO3Kernel
%
% Output
%  SO3F - @SO3FunHarmonic
%
% See also
% SO3FunHarmonic/conv SO3FunRBF/conv SO3Kernel/conv S2FunHarmonic/conv S2Kernel/conv 

if isnumeric(SO3F1)
  SO3F = conv(SO3F2,SO3F1,varargin{:});
  return
end

SO3F = conv(SO3FunHarmonic(SO3F1),SO3F2,varargin{:});