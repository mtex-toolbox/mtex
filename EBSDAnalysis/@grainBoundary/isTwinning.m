function ind = isTwinning(gB, mori, threshold )
%
% Syntax
%
%   ind = gB.isTwinning(mori,2*degree)
%   ind = gB.isTwinning(CSL(3),2*degree)
%
% Input
%  

ind = false(size(gB));

% whiches phases to use
phase1 = find(cellfun(@(cs) isa(cs,'crystalSymmetry') && ...
  cs == mori.CS,gB.CSList));
phase2 = find(cellfun(@(cs) isa(cs,'crystalSymmetry') && ...
  cs == mori.SS,gB.CSList));

% cycle through all indexed phase transistions
pairs = allPairs(phase1,phase2);

for ip = 1:size(pairs,1)
      
  indPhase = gB.hasPhaseId(pairs(ip,1),pairs(ip,2));
  if pairs(ip,1) > pairs(ip,2)
    mori_local = inv(mori);
  else
    mori_local = mori;
  end
  ind(indPhase) = min(angle_outer(gB.subSet(indPhase).misorientation,mori_local),[],2)<threshold;

end

