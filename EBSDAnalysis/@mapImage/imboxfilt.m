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
%   mg = imboxfilt(mg)        % 3 x 3
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
    mg(n).img(:,:,c) = boxMean(mg(n).img(:,:,c),k);
  end

end

end

% =========================================================================
function v = boxMean(v,k)
% the mean of the finite values under a k(1) x k(2) box, border replicated

ok = isfinite(v);

% sum and count separately, so the mean is over what was actually there
s = v; s(~ok) = 0;

s = boxSum(s,k);
n = boxSum(double(ok),k);

v = s ./ n;
v(n == 0) = NaN;

end

% =========================================================================
function s = boxSum(s,k)
% a separable box sum with the border replicated

p = (k-1)/2;

s = padReplicate(s,p);

% ones(1,k)/1 along each axis in turn - conv2 takes the two 1-D kernels
s = conv2(ones(k(1),1),ones(1,k(2)),s,'valid');

end

% =========================================================================
function A = padReplicate(A,p)
% repeat the border rows and columns p(1) and p(2) deep

if p(1) > 0
  A = A([ones(1,p(1)), 1:size(A,1), size(A,1)*ones(1,p(1))], :);
end
if p(2) > 0
  A = A(:, [ones(1,p(2)), 1:size(A,2), size(A,2)*ones(1,p(2))]);
end

end
