function  omega = getMaxAngle(cs,ss)
% get the maximum angle of a fundamental region without interplay

% TODO: function name does not reflect what this functions does
if nargin < 2 || length(ss) <= 1
  omega = pi/max(nfold(cs));
else
  % as we don't now which rotation axes fall together make it general.
  omega = angle_outer(cs,ss);
  omega = min(omega(omega>1e-1)/2);
end
