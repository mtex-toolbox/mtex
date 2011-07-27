function circle(x,y,theta,varargin)
% Plot Circle

minrho = getappdata(gcf,'minrho');
maxrho = getappdata(gcf,'maxrho');

if isappr(maxrho-minrho,2*pi)
  
  [dx,dy] = projectData(theta,minrho,varargin{:});
  r = norm([dx,dy]);
  h = optiondraw(builtin('rectangle','Position',[x-r,y-r,2*r,2*r],'Curvature',[1,1]),varargin{:});
else
  
  rho = linspace(minrho,maxrho,100);
  if isnumeric(theta)
    theta = theta*ones(1,length(rho));
  else
    theta = theta(rho);
  end
  
  if check_option(varargin,'boundary')
    rho = [0,rho,0];
    theta = [0,theta,0];
  end
    
  [dx,dy] = projectData(theta,rho,varargin{:});
  %h = optiondraw(patch(x+dx,y+dy,1,'FaceColor','none','EdgeColor','k'),varargin{:});
  h = optiondraw(plot(x+dx,y+dy,'Color','k'),varargin{:});
end

% control legend entry
setLegend(h,'off');
