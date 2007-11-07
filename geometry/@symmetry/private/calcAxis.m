function saxis  = calcAxis(System,axis,angle)
% calculate crystal axes

switch System
    
  case {'monocline','tricline'}
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
