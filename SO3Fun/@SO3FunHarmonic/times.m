function SO3F = times(SO3F1,SO3F2)
% overloads SO3F1 .* SO3F2
%
% Syntax
%   sF = SO3F1.*SO3F2
%   sF = a.*SO3F1
%   sF = SO3F1.*a
%
% Input
%  SO3F1, SO3F2 - SO3FunHarmonic
%
% Output
%  SO3F - SO3FunHarmonic
%

if isnumeric(SO3F1) 
  SO3F = SO3F2;
  SO3F.fhat = SO3F.fhat*SO3F1;
elseif isnumeric(SO3F2)
  SO3F = SO3F1;
  SO3F.fhat = SO3F.fhat*SO3F2;
elseif isa(SO3F2,'SO3Fun')
  warning('not implemented yet');
  % if adding this lines insert line 125 in SO3FunHarmonic to get static
  % method quadratur but first write quadratureSOGrid_chebyshev.m

  %f = @(v) SO3F1.eval(v) .* SO3F2.eval(v);
  %SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', min(getMTEXpref('maxBandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));
else
  SO3F = SO3F2.*SO3F1;
end

end
