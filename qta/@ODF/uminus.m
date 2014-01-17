function odf = uminus(odf)
% superposeing two ODFs
%
% overload the - operator, i.e. one can now write - @ODF
%
% See also
% ODF_index ODF/mtimes

for i = 1:numel(odf)
  odf(i).weight = -odf(i).weight;
end
