function b = boundary(sR)
% compute boundary points

b = vector3d;

% plot the region
omega = linspace(0,2*pi,721);
for i=1:length(sR.N)
  
  rot = rotation.byAxisAngle(sR.N(i),omega);
  bigCircle = rotate(orth(sR.N(i)),rot);
  v = sR.alpha(i) * sR.N(i) + sqrt(1-sR.alpha(i)^2) * bigCircle;
  
  ind = (imag(v.x).^2 + imag(v.y).^2 + imag(v.z).^2) < 1e-5;
  v = v(ind);
  
  b = [b;v(sR.checkInside(v))]; %#ok<AGROW>
end

end
