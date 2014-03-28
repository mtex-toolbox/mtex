function plot(s,varargin)
% plot symmetry
%
% Input
%  s - symmetry
%
% Output
%
% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]

mtexFigure;
washold = getHoldState;
hold on

if check_option(varargin,'hkl')

  % which directions to plot
  m = [Miller(1,0,0,s),Miller(0,1,0,s),...
    Miller(0,0,1,s),Miller(1,1,0,s),...
    Miller(0,1,1,s),Miller(1,0,1,s),...
    Miller(1,1,1,s)];

  m = unique(m);

  % plot them    
  m(1).scatter('symmetrised','labeled','MarkerEdgeColor','k','grid',varargin{:});
  hold all;
  for i = 2:length(m)
    m(i).scatter('symmetrised','labeled','MarkerEdgeColor','k','grid',varargin{:});
  end

  % postprocess figure
  setappdata(gcf,'CS',s);
  set(gcf,'tag','ipdf');
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  
else
    
  symbolSize = 0.15*get_option(varargin,'symbolSize',1);    
  
  % determine symmetry axes
  rot = rotation(s);
  
  Improper = isImproper(rot);
  [axes,angle] = getMinAxes(rot(~Improper));
      
  for i = 1:length(axes)    
    plotCustom(axes(i),{Symbol(angle(i),axes(i).rho)});
    hold on    
    plotCustom(-axes(i),{Symbol(angle(i),axes(i).rho,'FaceColor','k')});
  end
  
  [axes,angle] = getMinAxes(rot(Improper));
  for i = 1:length(axes)
    
    switch round(angle(i)/degree)
      case 180
        circle(axes(i),'linewidth',2,'color','k');
      case 90
        options = {'FaceColor','none','LineWidth',3};
        plotCustom(axes(i),{@(ax,x,y) square(x,y,symbolSize,'parent',ax,options{:})});
        plotCustom(-axes(i),{@(ax,x,y) square(x,y,symbolSize,'parent',ax,options{:})});
      case 120
        % small circle
        plotCustom([axes(i),-axes(i)],{@(ax,x,y) ...
          ellipse(x,y,0.3*symbolSize,0.3*symbolSize,0,'parent',ax,'FaceColor','w')});
      case 60
        options = {'FaceColor','none','LineWidth',3};
        plotCustom([axes(i),-axes(i)],{@(ax,x,y) hexagon(x,y,1.2*symbolSize,'parent',ax,options{:})});
    end
  end
  
  mtexFig = mtexFigure;
  for ax = mtexFig.children
    set(ax,'xlim',1.1*get(ax,'xlim'));
    set(ax,'ylim',1.1*get(ax,'ylim'));
    %xlim(ax,'auto');
    %ylim(ax,'auto');
  end  
end

hold(washold);

function s = Symbol(angle,alpha,varargin)
switch round(angle/degree)
  case 180
    s = @(ax,x,y) ellipse(x,y,0.3*symbolSize,symbolSize,alpha,'parent',ax,varargin{:});
  case 120
    s = @(ax,x,y) triangle(x,y,0.8*symbolSize,'parent',ax,varargin{:});
  case 90
    s = @(ax,x,y) square(x,y,0.7*symbolSize,'parent',ax,varargin{:});
  case 60
    s = @(ax,x,y) hexagon(x,y,0.75*symbolSize,'parent',ax,varargin{:});
end
end


end



%
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
