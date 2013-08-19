function plotAngleDistribution(odf,varargin)
% plot axis distribution
%
% Input
%  odf - @ODF
%
% Options
%  RESOLUTION - resolution of the plots
%


% make new plot
[ax,odf,varargin] = getAxHandle(odf,varargin{:});
if isempty(ax), newMTEXplot;end

%
[f,omega] = calcAngleDistribution(odf,varargin{:});


% plot
%bar(omega/degree,max(0,f));
% xlim([0,max(omega)])

p = findobj(gca,'Type','patch');

if ~isempty(p)
  faktor = 100 / mean(f) / size(get(p(1),'faces'),1);
else
  faktor = 1;
end

optiondraw(plot(ax{:},omega/degree,faktor * max(0,f)),'LineWidth',2,varargin{:});

optionplot(omega/degree,faktor * max(0,f),varargin{:});
xlabel(ax{:},'orientation angle in degree')
