function cs = csOf(ebsd,phaseId)
% the crystal symmetry of one phase, whether CSList is a cell or an array

cs = ebsd.CSList(phaseId);
if iscell(cs), cs = cs{1}; end

end
