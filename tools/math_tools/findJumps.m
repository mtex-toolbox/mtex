function x = findJumps(fun,xmin,xmax)
% find all jumps of a monotonsly increasing function
%
% Syntax
%   x = findJumps(fun,xmin,xmax)
%
% Input
%
% Output
%

v = fun([xmin,xmax]);
m = (xmin + xmax)./2;

if v(1) == v(2)
  
  x = [];
  
elseif xmax - xmin < 1e-5
  
  x = m;
  
else
    
  x = [findJumps(fun,xmin,m),findJumps(fun,m,xmax)];
  
end

end