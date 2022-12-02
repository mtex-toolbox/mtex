function hist(SO3F,varargin)
% calculates a histogram of an SO3Fun
%
% Input
%  SO3F - @SO3Fun
%
% Options
%  resolution - resolution used for calculation (default = 5*degree)
%
% See also
%  savefigure

% eval SO3Fun
SO3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,varargin{:});
d = eval(SO3F,SO3G,'loosely');

% make log histogram 
m = max(d(:));
p = m^(1/10);
if p > 1.75, p = round(p);end

me = round(log(m)/log(p));

[h,xout] = hist(d,p.^(-3:me),varargin{:});
bar(h)

for i = 1:length(xout)
  l{i} = num2str(xout(i),2);
end

set(gca,'XTickLabel',l);

