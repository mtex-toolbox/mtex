function [rgb,options] = om_AxisAngle(o,varargin)
% converts orientations to rgb values

if check_option(varargin,'center')
  center = get_option(varargin,'center');
  options = {};
else
  center = mean(o);
  options = {'center',center};
end

mori = inverse(center) * o;

s = disjoint(get(mori,'CS'),get(mori,'SS'));
omega = angle(mori);
v = axis(mori);

omega = omega ./ quantile(omega,0.75);
rgb = h2HSV(v,s,'grayValue',omega);

