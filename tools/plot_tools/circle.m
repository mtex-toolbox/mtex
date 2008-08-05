function circle(x,y,r,varargin)
% Plot Circle

rectangle('Position',[x-r,y-r,2*r,2*r],'Curvature',[1,1],varargin{:});
