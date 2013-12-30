function notIndexed = isNotIndexed(ebsd)
% returns if a spatially EBSD data is indexed
%
%% Example
% select all indexed EBSD data
%
%  ebsd(~isNotIndexed(ebsd))


notIndexedPhase = ebsd.phaseMap(cellfun('isclass',ebsd.CS,'char'));
notIndexed = ismember(get(ebsd,'phase'),notIndexedPhase);
