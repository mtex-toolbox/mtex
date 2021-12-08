function vF = rho(v)
%
% Gives the vector in the tangential plane in v in the direction rho
%

if nargin == 1

  vF = local(v);

else

  vF = S2VectorFieldHandle(@(r) local(r));

end


  function t = local(v)

    [th,rh] = polar(v);
    t = vector3d(-sin(rh).*sin(th), cos(rh).*sin(th), 0);

  end

%v = vector3d(-sin(v.rho).*sin(v.theta), cos(v.rho).*sin(v.theta), 0);


end
