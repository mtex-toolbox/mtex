function sF = conv(sF1,sF2,varargin)
% convolution of periodic functions
%
% Syntax
%   sF = conv(sF1, sF2)
%
% Input
%  sF1, sF1 - @S1Fun
%
% Output
%  sF   - @S1Fun
%
% See also
% S1FunHarmonic/conv


if isnumeric(sF1)
  sF = conv(sF2,sF1,varargin{:});
  return
end

sF = conv(S1FunHarmonic(sF1),sF2,varargin{:});