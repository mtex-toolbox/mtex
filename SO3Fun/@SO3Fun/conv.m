function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution of a rotational function with a rotational or spherical function
% or a kernel function
%
% For detailed information about the definition of the convolution take a 
% look in the <SO3FunConvolution.html documentation>.
% 
% The convolution of matrices of SO3Functions with matrices of SO3Functions 
% works elementwise.
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
%   SO3F = conv(SO3F1,SO3F2,'Right')
%   SO3F = conv(SO3F1,psi)
%   sF2 = conv(SO3F1,sF1)
%   sF2 = conv(SO3F1,phi)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  psi          - convolution @SO3Kernel
%  sF1          - @S2Fun
%  phi          - convolution @S2Kernel
%
% Output
%  SO3F - @SO3FunHarmonic
%  sF2  - @S2FunHarmonic
%
% See also
% SO3FunHarmonic/conv SO3FunRBF/conv SO3FunCBF/conv SO3Kernel/conv S2FunHarmonic/conv S2Kernel/conv 

if isnumeric(SO3F1)
  SO3F = conv(SO3F2,SO3F1,varargin{:});
  return
end

SO3F = conv(SO3FunHarmonic(SO3F1),SO3F2,varargin{:});