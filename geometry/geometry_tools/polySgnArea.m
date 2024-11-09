function area = polySgnArea(x,y,grainStart)
% area of an orientation with sign depending of orientation
%
%

area = (y(2:end)-y(1:end-1)) .* (x(2:end)+x(1:end-1));

if nargin == 3
  
  ind = repelem(1:length(grainStart)-1,diff(grainStart)).';

  % set the value for last entry of each loop to zero
  area(grainStart(2:end)-1) = 0;

  area = 0.5 * accumarray(ind,area);

else

  area = 0.5*sum(area);

end
  
end
