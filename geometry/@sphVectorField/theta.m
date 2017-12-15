function v = theta(v)
%
% Gives the vector in the tangential plane in v in the direction theta
%

v = vector3d(cos(v.rho).*cos(v.theta), sin(v.rho).*cos(v.theta), -sin(v.theta));

end
