function [sym1,sym2] = extractSym(obj)
% extract left and right symmetry from various objects

sym2 = [];
if isa(obj,'symmetry')
  sym1 = obj;
  sym2 = obj;
elseif isa(obj,'orientation')
  sym1 = obj.SS;
  sym2 = obj.CS;
elseif isa(obj,'Miller')
  sym1 = obj.CS;
elseif isa(obj,'quaternion') || isa(obj,'vector3d')
  sym1 = [];
else
  try
    sym1 = obj.CS;
  catch
    sym1 = [];
  end
end

end
