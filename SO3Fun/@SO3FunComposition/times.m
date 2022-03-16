function odf = times(x,y)
% scaling of the ODF
%
% overload the * operator, i.e. one can now write x*@ODF or @ODF*y in order
% to scale an ODF
%
% See also
% ODF/ODF ODF/plus

if isa(x,'ODF') && isa(y,'double')
  odf = x;
  f = y;
elseif isa(y,'ODF') && isa(x,'double')
  odf = y;
  f = x;
elseif isa(y,'ODF') && isa(x,'ODF')
  warning('not implemented yet');
  % TODO: go to SO3FunHarmonic
  %SO3F = times@SO3Fun(SO3F1,SO3F2);
  %SO3F = SO3FunHarmonic(SO3F,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));
end

odf.weights = odf.weights .* f;

% Error in last time by odf.weights