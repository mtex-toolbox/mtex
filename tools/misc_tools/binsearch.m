function x = binsearch(f,a,b,varargin)
% binaer search for zero in a motonously increasing function

epsilon = get_option(varargin,'ACCURACY',10^(-15));
x = 0.5*(a+b);
y = f(x);

while abs(y) > epsilon
  if f(x)>0
    b = x;
  else
    a = x;
  end
  x = 0.5*(a+b);
  y = f(x);
end
