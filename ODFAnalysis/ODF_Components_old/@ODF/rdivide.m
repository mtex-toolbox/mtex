function odf = rdivide(odf,s)
% scaling of the ODF
%
% overload the ./ operator, i.e. one can now write @ODF ./ [1 2 3]  in order
% to scale an ODF by different factors
%
% See also
% ODF/ODF ODF/plus ODF/mtimes

argin_check(odf,'ODF');
argin_check(s,'double');

odf.weighs =  odf.weighs ./ s; 

