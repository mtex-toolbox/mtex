function value = mPrime(sS1,sS2)
% m' parameter from Luster and Morris in 1995
%
% Description
%
% The 
%
% $$m'=(\vec n_{\text{in}} \cdot \vec n_{\text{out}}) (\vec d_{\text{in}}
% \cdot \vec d_{\text{out}})$$
% 
%
% Syntax
%   mPrime(sS1,sS2)
%
% Input
%  sS1, sS2 - slipSystem
%
% Example
%
%
% See also
%

value = abs(dot(sS1.b.normalize,sS2.b.normalize,'noSymmetry') .* ...
  dot(sS1.n.normalize,sS2.n.normalize,'noSymmetry'));

end