function A=calcChebyshevCoeff(K,L,varargin)
% calculate Chebyshev coefficients
%
%

maxAngle = get_option(varargin,'maxAngle',pi);

fun = @(omega,l) K(cos(omega/2)).*sin((2*l+1)*omega./2).*sin(omega./2);

warning off; %#ok<*WNOFF>
A = zeros(1,L+1);
if exist('quadgk','file')
  for l = 0:L
    A(l+1) = 2/pi*quadgk(@(omega) fun(omega,l) ,0,maxAngle,'MaxIntervalCount',2000);
  end
else
  for l = 0:L   
    A(l+1) = 2/pi*quadl(@(omega) fun(omega,l) ,0,maxAngle);
  end
end

