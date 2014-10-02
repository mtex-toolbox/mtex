function n = multiplicityPerpZ(cs)
% maximum angle rho

isPerpZ = isnull(dot(cs.axis,zvector)) & ~isnull(angle(cs));

if any(isPerpZ(:))
  n = round(2*pi/min(abs(angle(cs.subSet(isPerpZ)))));
else
  n = 1;
end

