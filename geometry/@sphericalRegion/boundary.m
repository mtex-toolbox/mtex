function b = boundary(sR)
% compute boundary points

b = vector3d;

% plot the region
omega = linspace(0,2*pi,721);
for i=1:length(sR.N)
  
  rot = rotation('axis',sR.N(i),'angle',omega);
  bigCircle = rotate(orth(sR.N(i)),rot);
  v = sR.alpha(i) * sR.N(i) + sqrt(1-sR.alpha(i)^2) * bigCircle;
  
  b = [b;v(sR.checkInside(v))]; %#ok<AGROW>
end

end
