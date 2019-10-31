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
end

odf.weights = odf.weights .* f;
