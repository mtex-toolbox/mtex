function mg = imboxfilt(mg,k)
% smooth one or more images with a box filter
%
% Cross correlation dislikes noise, so a light box filter before registration
% is the usual first step. This is the Image Processing Toolbox function of
% the same name, for @mapImage and without the toolbox: the box is separable,
% so it is two 1-D convolutions rather than one 2-D one.
%
% Syntax
%
%   mg = imboxfilt(mg)        % 3 × 3
%   mg = imboxfilt(mg,5)
%   mg = imboxfilt(mg,[3 7])  % rows, columns
%
% Input
%  mg - @mapImage, one or an array
%  k  - box size in pixels, odd. Scalar, or [rows cols]
%
% Output
%  mg - the same images, filtered
%
% Description
% Edges are handled by replicating the border, as imboxfilt does, so the
% filtered image does not darken towards its frame. Every channel is filtered
% on its own.
%
% Non finite values are excluded rather than propagated: a NaN would
% otherwise spread over the whole box. Each output is the mean of the finite
% inputs under the box, and stays NaN only where none of them were finite.
% imboxfilt itself has no such behaviour - it would return NaN for the whole
% neighbourhood - which matters here because a resampled map is padded with
% NaN by construction.
%
% See also
% mapImage mapImage/rescale mapImage/edgeMap

if nargin < 2, k = 3; end

if isscalar(k), k = [k k]; end

assert(all(mod(k,2) == 1) && all(k > 0),'MTEX:mapImage:badBoxSize',...
  'The box size has to be odd and positive, got %s.',mat2str(k));

for n = 1:numel(mg)

  if isempty(mg(n).img), continue; end

  for c = 1:mg(n).nChannel
    % a box that shrinks at the border and around a missing value
    mg(n).img(:,:,c) = movmean(movmean(mg(n).img(:,:,c),k(1),1,'omitnan'),k(2),2,'omitnan');
  end

end

end
