function circle(x,y,r,varargin)
% Plot Circle

minrho = get_option(varargin,'maxrho',0);
maxrho = get_option(varargin,'maxrho',2*pi);
if isappr(maxrho-minrho,2*pi)
  h = optiondraw(rectangle('Position',[x-r,y-r,2*r,2*r],'Curvature',[1,1]),varargin{:});
else
  rho = linspace(minrho,maxrho,100);
  [dx,dy] = projectData([0,rho],[0,pi/2*ones(1,length(rho))]);
  h = optiondraw(patch(x+dx,y+dy,1,'FaceColor','none','EdgeColor','k'),varargin{:});
end

% control legend entry
setLegend(h,'off');
