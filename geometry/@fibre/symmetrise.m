function f = symmetrise(f,varargin)	
% all crystallographically equivalent fibres

if isa(f.h,'Miller')
  
  [f.h,l] = f.h.symmetrise;

  f.r = repelem(f.r,l);
  
end
  
if isa(f.r,'Miller')
  
  [f.r,l] = f.r.symmetrise;

  f.h = repelem(f.h,l);
  
end
