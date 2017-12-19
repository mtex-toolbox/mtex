function v = rho(v)
%
% Gives the vector in the tangential plane in v in the direction rho
%

v = vector3d(-sin(v.rho).*sin(v.theta), cos(v.rho).*sin(v.theta), 0);

end
