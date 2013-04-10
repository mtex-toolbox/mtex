function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor


if check_option(h,'uvw')
  mv = v2d(h);  
else
  mv = v2m(h);
end

mv = mv(:,[1 2 end])';

mbr = selectMaxbyColumn(abs(mv));

h = h./reshape(mbr.*round(mbr),size(h));
mv = mv * diag(1./mbr.*round(mbr));

tol = get_option(varargin,{'tol','tolerance'},1*degree);
maxHKL = get_option(varargin,'maxHKL',12);

for im = 1:numel(h)
  
  mm = mv(:,im) * (1:maxHKL);  
  rm = round(mm);
  
  e = sum(bsxfun(@rdivide,mm.*rm,sqrt(sum((mm).^2,1)).*sqrt(sum((rm).^2,1))),1);
  
  e = round(e*1e7);
  [e,j] = min(e);
 
  h.vector3d(im) = h.vector3d(im)*j;
  
end







