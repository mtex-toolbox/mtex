function odf = mrdivide(odf,s)
% scaling of the ODF
%
% overload the / operator, i.e. one can now write @ODF / 2  in order
% to scale an ODF
%
% See also
% ODF/ODF ODF/plus ODF/mtimes

argin_check(odf,'ODF');
argin_check(s,'double');

odf.weights = odf.weights ./ s;

