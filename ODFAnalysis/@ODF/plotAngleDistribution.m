function plotAngleDistribution(odf,varargin)
% plot axis distribution
%
% Input
%  odf - @ODF
%
% Options
%  resolution - resolution of the plots
%

% get axis
ax = get_option(varargin,'parent',gca);

% compute angle distribution
[f,omega] = calcAngleDistribution(odf,varargin{:});

% plot
p = findobj(ax,'Type','patch');

if ~isempty(p)
  faktor = 100 / mean(f) / size(get(p(1),'faces'),1);
else
  faktor = 1;
end

optiondraw(plot(omega/degree,faktor * max(0,f),'parent',ax),'LineWidth',2,varargin{:});

xlabel(ax,'orientation angle in degree')
