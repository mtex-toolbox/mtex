function area = polySgnArea(x,y)
% area of an orientation with sign depending of orientation

area = 0.5*sum((y(2:end)-y(1:end-1)) .* (x(2:end)+x(1:end-1)));
  
end
