function n = multiplicityZ(cs)
% maximum angle rho

isZ = isnull(1-abs(dot(cs.axis,zvector))) & ~isnull(cs.angle);

if any(isZ(:))
  n = round(2*pi/min(abs(angle(cs.subSet(isZ)))));
else
  n = 1;
end
