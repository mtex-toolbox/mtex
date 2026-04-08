function [SRight,SLeft] = extractSym(list)
% extract crystal (SRight) and specimen (SLeft) symmetry from list of input 
% arguments. The first 2 symmetries of the list are returned. If there is
% none or just one symmetry in the list, the remaining outputs are set to 
% standard specimen symmetry.

SLeft = specimenSymmetry;
SRight = SLeft;

isSym = cellfun(@(x) isa(x,'symmetry'),list,'UniformOutput',true);

if any(isSym)
  pos = find(isSym,1);
  SRight = list{pos};
  isSym(pos) = false;
  
  if any(isSym), SLeft = list{find(isSym,1)}; end
end

end