function n = multiplicityPerpZ(cs)
% maximum angle rho

isPerpZ = isnull(dot(cs.rot.axis,zvector)) & ~isnull(cs.rot.angle);

if any(isPerpZ(:))
  n = round(2*pi/min(abs(angle(cs.rot(isPerpZ)))));
else
  n = 1;
end
