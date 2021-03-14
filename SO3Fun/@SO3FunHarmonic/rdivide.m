function SO3F = rdivide(SO3F1, SO3F2)
%
% Syntax
%   SO3F = SO3F1./SO3F2
%   SO3F = SO3F1./a
%   SO3F = a./SO3F1
%
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%  a - double
%
% Output
%  SO3F - @SO3FunHarmonic
%

if isnumeric(SO3F1)
  warning('not implemented yet');
  % if adding this lines insert line 125 in SO3FunHarmonic to get static
  % method quadratur but first write quadratureSOGrid_chebyshev.m

  %f = @(v) SO3F1./SO3F2.eval(v);
  %SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', min(getMTEXpref('maxBandwidth'),2*SO3F2.bandwidth));
elseif isnumeric(SO3F2)
  SO3F = SO3F1.*(1./SO3F2);
else
   warning('not implemented yet');
  % if adding this lines insert line 125 in SO3FunHarmonic to get static
  % method quadratur but first write quadratureSOGrid_chebyshev.m

  %f = @(v) SO3F1.eval(v)./SO3F2.eval(v);
  %SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', min(getMTEXpref('maxBandwidth'),2*max(SO3F1.bandwidth, SO3F2.bandwidth)));
end

end

