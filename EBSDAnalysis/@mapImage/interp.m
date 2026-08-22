function v = interp(mg,pos,varargin)
% the image values at arbitrary positions
%
% This is the fast path a regular grid buys: the query reduces to fractional
% row and column coordinates, so it is a griddedInterpolant rather than the
% scatteredInterpolant @EBSD/interp has to use for grids that may be
% rotated or distorted.
%
% Resampling onto another grid is this plus a target position set, and
% correcting a distortion is the same call with inv(T):
%
%   v = interp(mg, eval(inv(T),target.pos))
%
% Syntax
%
%   v = interp(mg,pos)
%   v = interp(mg,pos,'nearest')
%   v = interp(mg,pos,'extrapolationMethod','nearest')
%
% Input
%  mg  - @mapImage
%  pos - @vector3d, where to sample
%
% Output
%  v - values, size(pos) by nChannel
%
% Options
%  linear, nearest, cubic, spline - interpolation method, default linear
%  extrapolationMethod            - default 'none', i.e. NaN outside
%
% See also
% mapImage mapImage/pos2ind EBSD/interp

method = 'linear';
for m = {'nearest','linear','cubic','spline','makima'}
  if check_option(varargin,m{1}), method = m{1}; end
end

% outside the image there is no measurement, and inventing one silently is
% how a registration ends up aligned to its own padding
extrap = get_option(varargin,'extrapolationMethod','none');

[ri,ci] = gridCoordinates(mg,pos);

sz = gridSize(mg);
gi = griddedInterpolant({1:sz(1),1:sz(2)},mg.img(:,:,1),method,extrap);

k = mg.nChannel;
out = zeros([numel(ri) k]);

for c = 1:k
  if c > 1, gi.Values = mg.img(:,:,c); end
  out(:,c) = gi(ri(:)+1, ci(:)+1);
end

if k == 1
  v = reshape(out,size(ri));
else
  v = reshape(out,[size(ri) k]);
end

end
