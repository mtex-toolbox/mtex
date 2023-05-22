function v = theta(v)
%
% Gives the vector in the tangential plane in v in the direction theta
%

if nargin == 1
  v = vector3d(cos(v.rho).*cos(v.theta), sin(v.rho).*cos(v.theta), -sin(v.theta));
else
  v = zvector;
end


end
