function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor


if check_option(h,'uvw')
  mv = v2d(h);  
else
  mv = v2m(h);
end

mv = mv(:,[1 2 end])';

mbr = reshape(selectMaxbyColumn(abs(mv)),size(h));

tol = get_option(varargin,{'tol','tolerance'},1*degree);
maxHKL = get_option(varargin,'maxHKL',12);

for im = 1:length(h)
%   
  mm = mv(:,im)/mbr(im) * (1:maxHKL);  
  rm = round(mm);

  e = sum(mm ./ repmat(sqrt(sum(mm.^2,1)),3,1) .* rm ./ repmat(sqrt(sum(rm.^2,1)),3,1));
  
  e = round(e*1e7);
  [e,j] = sort(e,'descend');
  
  h(im) = h(im)*(j(1)/mbr(im)); 
end





