function saxis  = calcAxis(System,axis,angle)
% calculate crystal axes

if axis(3) == 0, axis(3) = max(axis);end
if axis(3) == 0, axis(3) = 1;end

if axis(1) == 0, axis(1) = axis(2);end
if axis(2) == 0, axis(2) = axis(1);end
if axis(2) == 0, 
  axis(2) = axis(3);
  axis(1) = axis(3);
end

if angle(1) == 0
  if angle(2) == 0, angle(2) = pi/2;end
  angle(1) = pi - angle(2);
end
if angle(2) == 0,  angle(2) = pi - angle(1);end
if angle(3) == 0, angle(3) = pi/2;end

switch System
    
  case {'monocline','triclinic','monoclinic','tricline'}
    saxis = xvector;
    saxis(2) = cos(angle(3)) * xvector + sin(angle(3)) * yvector;
    saxis(3) = cos(angle(2)) * xvector + ...
      (cos(angle(1)) - cos(angle(2)) * cos(angle(3)))/sin(angle(3)) * yvector +...
      sqrt(1+2*prod(cos(angle)) - sum(cos(angle).^2))/sin(angle(3)) * zvector;

    saxis = axis .* saxis;

  case 'orthorhombic'
    saxis = axis.*[xvector,yvector,zvector];
  case 'tetragonal'
    saxis = [axis(1)*xvector,axis(1)*yvector,axis(end)*zvector];
  case {'trigonal','hexagonal'}
    saxis = [axis(1)*vector3d(cos(pi/6),-sin(pi/6),0),...
      axis(1)*yvector,axis(end)*zvector];
  case 'cubic'
    saxis = [xvector,yvector,zvector];
end
