function ind = binary_search(x,y)
% searches for y in x 
%
%% Input
%  x - double
%  y - double
%
%% Output
% ind - integer

a = 1;
c = 1;
b = length(x);

while b - a > 1
  
  c = round((a+b)./2);
  
  if y > x(c)
    
    a = c;
    
  else
    
    b = c;
    
  end  
end

if x(c) - x(a) < x(b) - x(c)
  
  ind = a;
  
else

  ind = b;

end
