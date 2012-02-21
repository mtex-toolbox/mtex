function odf = uminus(odf)
% superposeing two ODFs
%
% overload the - operator, i.e. one can now write - @ODF
%
%% See also
% ODF_index ODF/mtimes

for i = 1:length(odf)
  odf(i).c = -odf(i).c;
  odf(i).c_hat = -odf(i).c_hat;
end
