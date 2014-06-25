function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor


switch h.dispStyle
  
  case 'uvw'
    mv = v2d(h);  
  case 'hkl'
    mv = v2m(h);
  otherwise
    return;
end

mv = mv(:,[1 2 end])';

mbr = reshape(selectMaxbyColumn(abs(mv)),size(h));

maxHKL = get_option(varargin,'maxHKL',12);

fak = ones(size(h));
for im = 1:size(mv,2)
%   
  mm = mv(:,im)/mbr(im) * (1:maxHKL);  
  rm = round(mm);

  e = sum(mm ./ repmat(sqrt(sum(mm.^2,1)),3,1) .* rm ./ repmat(sqrt(sum(rm.^2,1)),3,1));
  
  e = round(e*1e7);
  [~,j] = min(e);
  
  fak(im) = j/mbr(im);
  
end

h = h .* fak;
