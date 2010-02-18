function hist(odf,varargin)
% calcualtes a histogram of ODF
%
%% Input
%  odf - @ODF
%
%% Options
%  resolution - resolution used for calculation (default = 5*degree)
%
%% See also
%  savefigure

% eval odf
resolution = get_option(varargin,'resolution',5*degree);
[CS,SS] = getSym(odf);
SO3G = SO3Grid(resolution,CS,SS);
d = eval(odf,SO3G,'loosely'); %#ok<GTARG>

% make log histogram 
m = max(d(:));
p = m^(1/10);
if p > 1.75, p = round(p);end

me = round(log(m)/log(p));

[h,xout] = hist(d,p.^(-3:me),varargin{:});
bar(h)

for i = 1:length(xout)
  l{i} = num2str(xout(i),2); %#ok<AGROW>
end

set(gca,'XTickLabel',l);

