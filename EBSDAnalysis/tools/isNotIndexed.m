function notIndexed = isNotIndexed(obj)
% returns if a spatially EBSD data is indexed
%
% Example
%   ebsd(~isNotIndexed(ebsd)) %select all indexed EBSD data


notIndexedPhase = find(cellfun('isclass',obj.allCS,'char'));
notIndexed = ismember(obj.phaseId,notIndexedPhase);
