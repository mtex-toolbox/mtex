function [f,l] = symmetrise(f,varargin)  
% all crystallographically equivalent fibres
%
%
% Options
%  unique - return only 

if isa(f.h,'Miller')
  
  if check_option(varargin,'unique')
  
    [f.h,l,sym] = f.h.symmetrise('unique','keepAntipodal');

    o1 = repelem(f.o1,l);
    o2 = repelem(f.o2,l);
    
    f.o1 = o1(:) .* inv(sym(:));
    f.o2 = o2(:) .* inv(sym(:));
    
  else
    
    f.h = f.h.symmetrise;
    f.o1 = (f.o1 * inv(f.CS.rot)).';
    f.o2 = (f.o2 * inv(f.CS.rot)).';
    
  end
  
end
  
if isa(f.r,'Miller')
  
  if check_option(varargin,'unique')

    [f.r,l,sym] = f.r.symmetrise('unique','keepAntipodal');

    o1 = repelem(f.o1,l);
    o2 = repelem(f.o2,l);
    
    f.o1 = sym(:) .* o1(:);
    f.o2 = sym(:) .* o2(:);
  else
    
    f.r = f.r.symmetrise;
    f.o1 = f.SS * f.o1;
    f.o2 = f.SS * f.o2;
    
  end
  
end
