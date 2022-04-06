function odf = mtimes(x,y)
% scaling of the ODF
%
% overload the * operator, i.e. one can now write x*@ODF or @ODF*y in order
% to scale an ODF
%
% See also
% ODF/ODF ODF/plus

odf = times(x,y);
