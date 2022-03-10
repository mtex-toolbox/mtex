function [SRight,SLeft] = extractSym(list)
% extract crystal (SRight) and specimen (SLeft) symmetry from list of input arguments

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