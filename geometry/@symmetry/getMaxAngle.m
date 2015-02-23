function  omega = getMaxAngle(cs,ss)
% get the maximum angle of a fundamental region without interplay

% TODO: function name does not reflect what this functions does
if nargin < 2 || length(ss) <= 1
  omega = pi/max(nfold(cs))/2;
else
  % as we don't now which rotation axes fall together make it general.
  omega = angle_outer(quaternion(cs),quaternion(ss));
  omega = omega(omega>1e-1);
  omega = min([pi/2;omega(:)/2]);
end
