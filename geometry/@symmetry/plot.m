function plot(s,varargin)
% visualize symmetry elements according to international table
%
% Syntax
%   plot(cs)
%   plot(cs,'symbolSize',2)
%
% Input
%  cs - crystalSymmetry
%

% extract symmetry elements
rot = rotation(s);
Improper = isImproper(rot);

axis = rot.axis;
omega = round(rot.angle./degree);
[uaxis, ~, id] = unique(axis,'antipodal');

% initalize plot
sP = newSphericalPlot(zvector,'upper',varargin{:},s.plotOptions{:});

% scale symbol size according to bounds
d = max(sP(1).bounds(3:4) - sP(1).bounds(1:2));
symbolSize = 0.15*get_option(varargin,'symbolSize',d/3);

hold on

% plot mirror planes
mir = Improper & rot.angle>pi-1e-4;
circle(rot(mir).axis,'linewidth',2,'color','k','doNotDraw');

for i = 1:length(uaxis)
  
  angleP = min(omega(~Improper(:) & id == i & omega(:)>0));
  angleI = min(omega(Improper(:) & id == i & omega(:)>0));
  n = [1,-1].*uaxis(i);
  
  if isempty([angleP,angleI]), continue; end
    
  switch min([angleP,angleI])
  
    case 180
      if angleP == 180
        plotCustom(n,{@(ax,x,y) ...
          ellipse(x,y,symbolSize,0.4*symbolSize,pi/2+n(1).rho,'parent',ax,'edgecolor','w')});
      end      
    case 120
      plotCustom(n,{@(ax,x,y) triangle(x,y,1.1*symbolSize,'parent',ax,'edgecolor','w')});
    case 90
      plotCustom(n,{@(ax,x,y) square(x,y,1.2*symbolSize,'parent',ax,'edgecolor','w')});        
      if angleP == 180
        plotCustom(n,{@(ax,x,y) ...
          square(x,y,0.9*symbolSize,'parent',ax,'FaceColor','w')});
        plotCustom(n,{@(ax,x,y) ellipse(x,y,symbolSize,0.4*symbolSize,0,'parent',ax)});      
      end
    case 60
      plotCustom(n,{@(ax,x,y) hexagon(x,y,1.2*symbolSize,'parent',ax,'edgecolor','w')});        
      if angleP == 120       
        plotCustom(n,{@(ax,x,y) ...
          hexagon(x,y,0.9*symbolSize,'parent',ax,'FaceColor','w')});
        plotCustom(n,{@(ax,x,y) triangle(x,y,0.8*symbolSize,'parent',ax)});      
      end
  end  
end

if any(rot(:)==-rotation.id)
  plotCustom(zvector*[1,-1],{@(ax,x,y) ...
    ellipse(x,y,0.4*symbolSize,0.4*symbolSize,0,'parent',ax,'FaceColor','w','linewidth',2)});
end

mtexFig = newMtexFigure;
for ax = mtexFig.children(:).'
  set(ax,'xlim',1.075*get(ax,'xlim'));
  set(ax,'ylim',1.075*get(ax,'ylim'));  
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
function triangle(x,y,d,varargin)

patch('vertices',[x+[-d;0;d],y+d*sqrt(3)/3*[-1;2;-1]],'faces',1:3,varargin{:});

end

function hexagon(x,y,d,varargin)

patch('vertices',[x+d*[0;sqrt(3)/2;sqrt(3)/2;0;-sqrt(3)/2;-sqrt(3)/2],...
  y+d*[-1;-0.5;0.5;1;0.5;-0.5]],'faces',1:6,varargin{:});

end

function square(x,y,d,varargin)

patch('vertices',[x+[0;d;0;-d],y+[-d;0;d;0]],'faces',1:4,varargin{:});

end
