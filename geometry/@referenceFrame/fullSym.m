function fr = fullSym(rf)
% the sibling of this frame carrying the largest group
%
% The inverse verb to <referenceFrame.stripSym.html |stripSym|>: where that
% one drops the claim a frame makes about symmetry, this one asks for it back.
% A direction that names one plane is written in a group-free frame, and the
% orientation it helps define still has to know the point group of its phase -
% <orientation.map.html |orientation/map|> is where the two meet.
%
% The answer comes from the register rather than from a stored parent. A
% stripped frame has no provenance in its key, so `mmm` and its proper group
% strip to one and the same frame and a remembered parent would be a coin
% flip between them. The largest group over one basis is unambiguous.
%
% Syntax
%   fr = fullSym(rf)
%
% Input
%  rf - @referenceFrame
%
% Output
%  fr - @referenceFrame
%
% See also
% referenceFrame/stripSym referenceFrame/sibling referenceFrame/properGroup

fr = rf;

if isempty(rf), return; end

sibs = referenceFrame.intern(rf,'-siblings-');

for k = 1:numel(sibs)
  if numSym(sibs{k}) > numSym(fr), fr = sibs{k}; end
end

end
