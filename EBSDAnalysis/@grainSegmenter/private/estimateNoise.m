function sigma = estimateNoise(ebsd)
% estimate the per pixel orientation noise from SECOND spatial differences
%
% First differences would also see any real orientation gradient inside a
% grain and would therefore overestimate the noise on deformed material.
% Second differences do not: a linear orientation ramp cancels exactly,
%
%   v(p-1) - 2 v(p) + v(p+1) = 0   for v linear in p
%
% so what is left is noise only. For independent noise of standard
% deviation sigma per tangent component the second difference has variance
% 6 sigma^2 per component, hence |d|^2 has mean 18 sigma^2 and follows
% 6 sigma^2 * chi^2 with 3 degrees of freedom. The median of that
% distribution is used rather than the mean, so that the triples which
% straddle a grain boundary or contain a misindexed pixel - a minority, but
% arbitrarily large ones - do not enter the estimate.
%
% Input
%  ebsd - @EBSDsquare
%
% Output
%  sigma - orientation noise per pixel, in rad

rot = ebsd.rotations;
ok  = ebsd.isIndexed & ~isnan(rot);

d2 = [secondDifference(rot,ok,1); secondDifference(rot,ok,2)];

if numel(d2) < 10
  error('too few valid pixel triples to estimate the noise level');
end

% median of chi^2 with 3 degrees of freedom
chi2med3 = 2.3659738843;

sigma = sqrt(median(d2) / (6*chi2med3));

end

% ---------------------------------------------------------------- helpers

function d2 = secondDifference(rot,ok,dim)
% squared length of the second difference along dimension dim

if size(rot,dim) < 3, d2 = []; return; end

if dim == 2, rot = rot.'; ok = ok.'; end

% first differences as tangent vectors, taken at the left pixel
a = rot(1:end-1,:);
b = rot(2:end,:);
v = log(itimes(a,b,true),'noSymmetry');  % inv(a) .* b

% second difference of a linear ramp vanishes, so no symmetry handling is
% needed here - all quantities involved are small
d = v(2:end,:) - v(1:end-1,:);

valid = ok(1:end-2,:) & ok(2:end-1,:) & ok(3:end,:);

d2 = norm(d(valid)).^2;
d2 = d2(:);

end
