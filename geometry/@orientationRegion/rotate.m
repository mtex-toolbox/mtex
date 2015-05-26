function oR = rotate(oR,varargin)
% rotate of a orientation region
%

oR.N = rotate(oR.N,varargin{:});
oR.V = rotate(oR.V,varargin{:});