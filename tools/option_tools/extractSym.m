function [SLeft,SRight] = extractSym(list)
% extract crystal and specimen symmetry from list of input arguments

SLeft = specimenSymmetry;
SRight = SLeft;

isSym = cellfun(@(x) isa(x,'symmetry'),list,'UniformOutput',true);

if any(isSym)
  pos = find(isSym,1);
  SLeft = list{pos};
  isSym(pos) = false;
  
  if any(isSym), SRight = list{find(isSym,1)}; end
end

end