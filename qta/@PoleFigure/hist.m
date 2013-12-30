function hist(pf,varargin)
% calcualte histogram of pole figures
%
%% Input
%  odf - @PoleFigure
%
%% Options
%  resolution - resolution used for calculation (default = 5*degree)
%
%% See also
% savefigure

s = GridLength(pf);

d = NaN(max(s),length(pf));

for i = 1:length(pf)
  d(1:s(i),i) = getdata(pf(i));
end

m = max(d(:));
p = m^(1/10);
if p > 1.75, p = round(p);end
me = round(log(m)/log(p));

[h,xout] = hist(d,p.^(-3:me),varargin{:});
bar(h,1.5)

for i = 1:length(xout)
  l{i} = num2str(xout(i),2); %#ok<AGROW>
end

set(gca,'XTickLabel',l);
