function nx = setNull(x,e)
% set approx zero to exact zero

if nargin == 1
    e = -10;
end

epsilon = exp(log(10)*e);
nx = x;
nx(abs(nx) < epsilon) = 0;
