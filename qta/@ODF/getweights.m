function w = getweights(odf)
% get weights of ODF components
%
%% Input
%  odf - @ODF
%
%% Output
%  w - weigths corresponding to the componentds odf(1),...,odf(N)
%
%% See also
% ODF/getdata

for i=1:length(odf)
  w(i) = sum(odf(i).c(:)); %#ok<AGROW>
end
