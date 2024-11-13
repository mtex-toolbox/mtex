function area = polySgnArea(x,y,polyStart)
% signed areas of a list of polygons
%
%
% Input
%  x,y - coordinates of the polygons
%  polyStart - indices of the first polygon in the list of vertices
%

area = (y(2:end)-y(1:end-1)) .* (x(2:end)+x(1:end-1));

if nargin == 3
  
  ind = repelem(1:length(polyStart)-1,diff(polyStart)).';

  % set the value for last entry of each loop to zero
  area(polyStart(2:end)-1) = 0;

  area = 0.5 * accumarray(ind,area);

else

  area = 0.5*sum(area);

end
  
end
