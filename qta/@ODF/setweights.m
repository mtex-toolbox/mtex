function nodf = setweights(odf,w)
% set weights of ODF components
%
%% Input
% odf - @ODF
% w   - new weights (double)
%
%% See also
% ODF/getweights


nodf = odf;
for i=1:length(odf)
  nodf(i).c_hat = odf(i).c_hat * w(i)/sum(odf(i).c(:));
  nodf(i).c = odf(i).c * w(i)/sum(odf(i).c(:));
end
