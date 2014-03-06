function pf = quantile(pf,p,varargin)
% quantile of polefigure
%
%% Input 
% pf  - @PoleFigure
% p   - upper quantile, if negative lower quantile
%
%% See Also
% ODF/quantile

if p < 0 
  c = @(c)~c;
  p = abs(p);
else
  c = @(c)c;
end

for l=1:length(pf)
  pf_data = getdata(pf(l));

  [pf_data ndx] = sort(pf_data);
  pd = cumsum(pf_data)./sum(pf_data);
  
  pf(l) = delete(pf(l), ndx( c(pd < p) ));  
end
