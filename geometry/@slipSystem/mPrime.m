function value = mPrime(sS1,sS2)
% m' parameter from Luster and Morris in 1995
%
% Description
%
% The 
%
% $$ m'=(\vec n_{\mathrm{in}} \cdot \vec n_{\mathrm{out}}) (\vec
% d_{\mathrm{in}} \cdot \vec d_{\mathrm{out}}) $$
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