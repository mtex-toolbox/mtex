function notIndexed = isNotIndexed(ebsd)


notIndexedPhase = ebsd.phaseMap(cellfun('isclass',ebsd.CS,'char'));
notIndexed = ismember(get(ebsd,'phase'),notIndexedPhase);
