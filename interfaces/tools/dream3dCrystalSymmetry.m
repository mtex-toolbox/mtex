function csList = dream3dCrystalSymmetry(crysm)
% crystal symmetries from the DREAM.3D CrystalStructures enumeration
%
% Input
%  crysm - list of enumeration values, 999 for unknown
%
% Output
%  csList - list of @crystalSymmetry, notIndexed for unknown entries

% the list is indexed by the zero based enumeration
dream3dCS = {'622','432','6','23','1','121','222','4','422','3','322','1'};
csList = repmat(notIndexed,1,length(crysm));
for k = 1:length(crysm)
  if crysm(k) >= 0 && crysm(k) < length(dream3dCS)
    csList(k) = crystalSymmetry(dream3dCS{crysm(k)+1},'mineral','unknown');
  end
end
