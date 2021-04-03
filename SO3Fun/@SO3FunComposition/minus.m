function odf = minus(o1,o2)
% superposeing two ODFs
%
% overload the - operator, i.e. one can now write @ODF - @ODF in order
% get the superposition of two ODFs
%
% See also
% ODF/ODF ODF/mtimes

odf = o1 + (-1).* o2;
