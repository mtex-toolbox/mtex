function mg = rescale(mg,varargin)
% stretch the values of one or more images to a common range
%
% Cross correlation compares two pictures that came off different detectors,
% so their absolute levels mean nothing to each other. Putting them on one
% range is the usual first step.
%
% Each image is rescaled on its own, and every channel of it together, so the
% colour balance of a multi channel image is preserved.
%
% Syntax
%
%   mg = rescale(mg)              % to [0,1]
%   mg = rescale(mg,lo,hi)
%   mg = rescale(mg,'perChannel')
%
% Input
%  mg     - @mapImage, one or an array
%  lo, hi - target range, default 0 and 1
%
% Output
%  mg - the same images, rescaled
%
% Flags
%  perChannel - rescale each channel separately rather than together
%
% Description
% Non finite values are ignored when the range is measured and left alone
% afterwards, so the padding an earlier resampling left behind neither
% skews the result nor becomes a number.
%
% A flat image has no range to stretch and is returned unchanged rather than
% divided by zero.
%
% See also
% mapImage mapImage/imboxfilt

perCh = check_option(varargin,'perChannel');

lohi = varargin(cellfun(@isnumeric,varargin));
if numel(lohi) >= 2
  lo = lohi{1}; hi = lohi{2};
else
  lo = 0; hi = 1;
end

for k = 1:numel(mg)

  if isempty(mg(k).img), continue; end

  if perCh
    for c = 1:mg(k).nChannel
      mg(k).img(:,:,c) = stretch(mg(k).img(:,:,c),lo,hi);
    end
  else
    mg(k).img = stretch(mg(k).img,lo,hi);
  end

end

end

% =========================================================================
function v = stretch(v,lo,hi)

ok = isfinite(v);
if ~any(ok(:)), return; end

vMin = min(v(ok)); vMax = max(v(ok));

% nothing to stretch, and nothing to divide by
if vMax <= vMin, return; end

v(ok) = lo + (hi-lo) * (v(ok) - vMin) ./ (vMax - vMin);

end
