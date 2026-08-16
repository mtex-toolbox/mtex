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
% orientation is the identity *and* every numeric per pixel property
% (image quality, fit metric, confidence index, ...) is exactly zero. That
% combination does not occur in real data.
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

% "orientation is zero" means zero as it stands in the file - a reference
% frame correction already applied to the data shows up as exactly that
% rotation here, not as the identity
isNull = ~isnan(ebsd.rotations) & angle(ebsd.rotations,ebsd.EulerCorrection) < 1e-8;
if ~any(isNull), return; end

nProps = 0;
for fn = fieldnames(ebsd.prop).'
  p = ebsd.prop.(char(fn));
  if ~isnumeric(p) || ~isreal(p) || numel(p) ~= length(ebsd), continue; end
  isNull = isNull & p(:) == 0;
  nProps = nProps + 1;
end

% with no property to corroborate it, a zero orientation says nothing
if nProps == 0 || ~any(isNull), return; end

ebsd.phaseId(isNull) = notIndexedId;
ebsd.rotations(isNull) = NaN;

end
