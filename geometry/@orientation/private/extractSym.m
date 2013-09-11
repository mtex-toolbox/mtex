function [sym1,sym2] = extractSym(obj)
% extract left and right symmetry from various objects

sym1 = symmetry;
sym2 = sym1;

if isa(obj,'symmetry')
  sym1 = obj;
  sym2 = obj;
elseif isa(obj,'orientation')
  sym1 = obj.SS;
  sym2 = obj.CS;
elseif isa(obj,'Miller')
  sym1 = get(obj,'CS');
end

end
