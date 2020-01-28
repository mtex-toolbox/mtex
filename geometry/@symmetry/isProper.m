function res = isProper(sym) 
% does it contain only proper rotations

if ~isempty(sym.properRef)

  res = sym.properRef == sym;
  
else
  
  res = ~any(sym.rot.i(:));
  
end