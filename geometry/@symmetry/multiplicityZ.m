function n = multiplicityZ(cs)
% maximum angle rho

isZ = isnull(1-abs(dot(cs.rot.axis,zvector))) & ~isnull(cs.rot.angle);

if any(isZ(:))
  n = round(2*pi/min(abs(angle(cs.rot(isZ)))));
else
  n = 1;
end
