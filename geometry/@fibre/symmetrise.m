function [f,l] = symmetrise(f,varargin)  
% all crystallographically equivalent fibres
%
%
% Options
%  unique - return only 

if numSym(f.CS) > 1

  if check_option(varargin,'unique')

    [f.h,l,sym] = symmetrise(f.h,f.CS,'unique','noAntipodal');

    o1 = repelem(f.o1,l);
    o2 = repelem(f.o2,l);

    f.o1 = o1(:) .* inv(sym(:));
    f.o2 = o2(:) .* inv(sym(:));

  else

    f.h = f.CS.rot * f.h;
    f.o1 = (f.o1 * inv(f.CS.rot)).';
    f.o2 = (f.o2 * inv(f.CS.rot)).';

  end
end

if numSym(f.SS) > 1
  
  if check_option(varargin,'unique')
    
    [~,l,sym] = symmetrise(f.r,f.SS,'unique','noAntipodal');
    
    o1 = repelem(f.o1,l);
    o2 = repelem(f.o2,l);
    
    f.h = repelem(f.h,l);
    f.o1 = sym(:) .* o1(:);
    f.o2 = sym(:) .* o2(:);
    
  else
    
    f.h = reshape(repelem(f.h,numSym(f.SS),1),numSym(f.CS)*numSym(f.SS),1);
    f.o1 = reshape(f.SS * f.o1,numSym(f.CS)*numSym(f.SS),1);
    f.o2 = reshape(f.SS * f.o2,numSym(f.CS)*numSym(f.SS),1);
    
  end
  
end
