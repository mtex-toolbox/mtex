function [sym1,sym2] = extractSym(obj)
% extract left and right symmetry from various objects

sym1 = specimenSymmetry;
sym2 = sym1;

if isa(obj,'symmetry')
  sym1 = obj;
  sym2 = obj;
elseif isa(obj,'orientation')
  sym1 = obj.SS;
  sym2 = obj.CS;
else
  try
    sym1 = obj.CS;
  end
end

end
