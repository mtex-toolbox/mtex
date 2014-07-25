function plotHKL(s,varargin)
% plot symmetry
%
% Input
%  s - symmetry
%
% Output
%
% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]

mtexFig = newMtexFigure;

% which directions to plot
m = [Miller(1,0,0,s),Miller(0,1,0,s),...
  Miller(0,0,1,s),Miller(1,1,0,s),...
  Miller(0,1,1,s),Miller(1,0,1,s),...
  Miller(1,1,1,s)];

m = unique(m);
options = [{'symmetrised','labeled','MarkerEdgeColor','k','grid','doNotDraw'},varargin];
  
% plot them
m(1).scatter(options{:});
hold all;
for i = 2:length(m)
  m(i).scatter(options{:});
end

% postprocess figure
setappdata(gcf,'CS',s);
set(gcf,'tag','ipdf');
mtexFig.drawNow(varargin{:});
    
