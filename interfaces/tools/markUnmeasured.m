function ebsd = markUnmeasured(ebsd)
% mark pixels that were never measured as notIndexed
%
% Description
%
% Some indexing programs write a value for every pixel of the scan grid,
% including the ones a ROI mask kept out of the run, and flag only the
% patterns they genuinely failed to index. The masked pixels then arrive as
% a perfectly valid looking phase sitting at orientation (0,0,0) with every
% quality measure at zero - EMSphInx does exactly this. Left alone they
% fuse into one huge spurious grain.
%
% A zero orientation on its own is a legitimate measurement, so it is not
% enough on its own: a pixel is only taken as never measured when its
% orientation is the identity *and* every quality measure the file provides
% (image quality, confidence index, fit metric, ...) is exactly zero. That
% combination does not occur in real data.
%
% Only quality measures count, not every numeric property: an SEM signal
% keeps reading outside the ROI, and MTEX adds index columns of its own
% (gridify writes oldId), so a rule over all properties would quietly
% never fire again the moment such a column is present.
%
% Syntax
%
%   ebsd = markUnmeasured(ebsd)
%
% Input
%  ebsd - @EBSD
%
% Output
%  ebsd - @EBSD, unmeasured pixels set to the notIndexed phase
%

% the notIndexed phase to move them to - without one there is nothing to do
notIndexedId = find(~[ebsd.CSList.isIndexed],1);
if isempty(notIndexedId), return; end

% zero as it stands in the file, i.e. the Euler correction - the tolerance covers
% the round-off of composing three rotations
isNull = ~isnan(ebsd.rotations) & angle(ebsd.rotations,ebsd.EulerCorrection) < 1e-3*degree;
isNull = isNull(:);
if ~any(isNull), return; end

nQuality = 0;
for fn = fieldnames(ebsd.prop).'
  if ~isQualityMeasure(char(fn)), continue; end
  p = ebsd.prop.(char(fn));
  if ~isnumeric(p) || ~isreal(p) || numel(p) ~= length(ebsd), continue; end
  isNull = isNull & p(:) == 0;
  nQuality = nQuality + 1;
end

% with no quality measure to corroborate it, a zero orientation says nothing
if nQuality == 0 || ~any(isNull), return; end

ebsd.phaseId(isNull) = notIndexedId;
ebsd.rotations(isNull) = NaN;

end

% -----------------------------------------------------------------------

function out = isQualityMeasure(name)
% does this property name describe how well the pattern was indexed?
%
% The names the EDAX and EMSphInx routes produce - .ang columns arrive
% lowercased through the generic loader, HDF5 data sets keep the spelling
% of the file - plus the Oxford equivalents, so the test does not depend on
% which of them wrote the map.

out = ~isempty(regexpi(name,['^(iq|imagequality|image_quality|ci|confidenceindex|' ...
  'confidence_index|confidence|metric|xc|fit|mad|error|bc|bs|bandcontrast|' ...
  'bandslope|quality)$'],'once'));

end
