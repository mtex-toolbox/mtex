function poly = selectPolygon(varargin)
% select a polygon by mouse
%
% Syntax
%   poly = selectPolygon
%   ebsd = ebsd(inpolygon(ebsd,poly))

disp('Use the mouse to select the vertices of a polygon.');
disp('Click right to finish your selection.')

poly = [];
button = 1;
hold on

h = line('xdata',[],'ydata',[],'Color','k','MarkerFaceColor','k','MarkerEdgeColor',...
  'w','MarkerSize',10,'LineWidth',2,'Marker','s');

while button == 1
  
    [xi,yi,button] = ginput(1);
    poly(end+1,:) = [xi,yi]; %#ok<AGROW>
    
    set(h,'XData',poly(:,1),'YData',poly(:,2));
    
end

% ensure the polygon is always closed
poly(end+1,:) = poly(1,:);
set(h,'XData',poly(:,1),'YData',poly(:,2));

hold off

