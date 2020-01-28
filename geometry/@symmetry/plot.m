function plot(s,varargin)
% visualize symmetry elements according to international table
%
% Syntax
%   plot(cs)
%   plot(cs,'symbolSize',2)
%   plot(cs,'symbolSize',2,'mirrorLineWidth',5)
%
% Input
%  cs - crystalSymmetry
%

% extract symmetry elements
rot = s.rot;
Improper = isImproper(rot);

axis = rot.axis;
omega = round(rot.angle./degree);
[uaxis, ~, id] = unique(axis,'antipodal','tolerance',0.1);
uaxis(uaxis.z < 0) = -uaxis(uaxis.z < 0);

% initalize plot
sP = newSphericalPlot(zvector,'upper',varargin{:},s.plotOptions{:});

% scale symbol size according to bounds
d = max(sP(1).bounds(3:4) - sP(1).bounds(1:2));
symbolSize = 0.15*get_option(varargin,'symbolSize',d/3);

hold on

% plot mirror planes
mir = Improper & rot.angle>pi-1e-4;
mlw = get_option(varargin,'mirrorLineWidth',4);
circle(rot(mir).axis,'linewidth',mlw,'color','k','doNotDraw');

for i = 1:length(uaxis)
  
  % proper multiplicity
  multiP = round(360./min(omega(~Improper(:) & id == i & omega(:)>0)));
  
  % improper multiplicity
  multiI = round(360./min(omega(Improper(:) & id == i & omega(:)>0)));
  n = [1,-1].*uaxis(i);
  
  if isempty([multiP,multiI]), continue; end
    
  multi = max([multiP,multiI]);
  
  % plot a proper rotation or the exterior of an improper rotation 
  if multi > 2 || ~isempty(multiP)
    plotCustom(n,{@(ax,x,y) npoly(x,y,multi,1.1*symbolSize,n(1).rho,'parent',ax,'edgecolor','w','linewidth',1)});
  end
  
  % if the improper multiplicity is larger then the proper multiplicity
  if multiI > multiP
    % plot the interior white
    plotCustom(n,{@(ax,x,y) ...
      npoly(x,y,multi,0.9*symbolSize,n(1).rho,'parent',ax,'FaceColor','w')});
    
    % and on top of it the proper multiplicity - a bit smaller
    plotCustom(n,{@(ax,x,y) npoly(x,y,multiP,0.9*symbolSize,n(1).rho,'parent',ax)});
  end
    
end

% mark inversion if present
if s.isLaue
  plotCustom(zvector*[1,-1],{@(ax,x,y) ...
    ellipse(x,y,0.4*symbolSize,0.4*symbolSize,0,'parent',ax,'FaceColor','w','linewidth',2)});
end

mtexFig = newMtexFigure;
for ax = mtexFig.children(:).'
  if length(sP.sphericalRegion.vertices) > 2
    delta = 0.1*max(sP.bounds([3,4])-sP.bounds([1,2]));
    set(ax,'xlim',sP.bounds([1,3]) + delta*[-1,1]);
    set(ax,'ylim',sP.bounds([2,4]) + delta*[-1,1]);
  else
    set(ax,'xlim',1.075*sP.bounds([1,3]));
    set(ax,'ylim',1.075*sP.bounds([2,4]));
  end
end
mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});

hold off

end

function ellipse(cx,cy,dx,dy,angle,varargin)

A = [[cos(angle) -sin(angle)];[sin(angle) cos(angle)]];
omega = linspace(0,2*pi,200);

xy = [sin(omega(:)) .* dx,cos(omega(:)) .* dy];

xy = (A * xy.').';
xy = bsxfun(@plus,xy,[cx,cy]);

patch('vertices',xy,'faces',1:size(xy,1),varargin{:});

end

%
function npoly(x,y,n,d,angle,varargin)

if n == 2
  ellipse(x,y,0.4*d,d,angle,varargin{:});
else

  omega = angle + pi + linspace(0,2*pi,n+1).';
  patch('vertices',[x + d * cos(omega), y+d*sin(omega)],'faces',1:n,varargin{:});
end

end
