function [sym1,sym2] = extractSym(obj)
% extract left and right symmetry from various objects

sym1 = symmetry;
sym2 = sym1;

switch class(obj)
  case 'symmetry'
    sym2 = obj;
  case 'orientation'
    sym1 = obj.SS;
    sym2 = obj.CS;
  case 'Miller'
    sym1 = get(obj,'CS');
end

end
