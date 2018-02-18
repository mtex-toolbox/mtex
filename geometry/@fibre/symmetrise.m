function f = symmetrise(f,varargin)  
% all crystallographically equivalent fibres

if isa(f.h,'Miller')
  
  [f.h,l,sym] = f.h.symmetrise;

  o1 = repelem(rotation(f.o1),l);
  f.o1 = reshape(orientation(o1 .* inv(sym),f.CS,f.SS),[],1);
  
  o2 = repelem(rotation(f.o2),l);
  f.o2 = reshape(orientation(o2 .* inv(sym),f.CS,f.SS),[],1);
  
end
  
if isa(f.r,'Miller')
  
  [f.r,l,sym] = f.r.symmetrise;

  o1 = repelem(rotation(f.o1),l);
  f.o1 = reshape(orientation(sym .* o1,f.CS,f.SS),[],1);
  
  o2 = repelem(rotation(f.o2),l);
  f.o2 = reshape(orientation(sym .* o2,f.CS,f.SS),[],1);
  
end
