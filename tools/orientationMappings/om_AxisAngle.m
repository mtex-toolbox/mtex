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
mori = project2FundamentalRegion(mori);

omega = abs(angle(mori)) ./ pi;

if check_option(varargin,'experimental')

  % computed relative distance to identity
  switch Laue(s)
  
    case '-1'
      omega = abs(angle(mori)) ./ pi;
    
    otherwise
    
      h = getFundamentalRegionRodriguez(s);
      h = h ./ norm(h).^2;
    
      rod = Rodrigues(mori);
      lambda = min(abs(abs(1./dot_outer(h,rod))));
    
      omega = atan(norm(rod)) ./ atan(reshape(lambda,size(rod)).*norm(rod));
      %omega = min(omega,1);
    
  end
else
  omega = min(1,omega ./ quantile(omega,0.75));
end


v = axis(mori);

rgb = h2HSV(v,s,'grayValue',omega,'antipodal');

return

cs = symmetry('m-3m');

r = S2Grid('plot');
o = rotation('axis',r,'angle',10*degree);
rod = Rodrigues(o);

h = getFundamentalRegionRodriguez(cs);
h = h ./ norm(h).^2;
    
lambda = min(abs(1./dot_outer(h,rod)));

plot(r,lambda)

omega = 2*atan(reshape(lambda,size(rod)).*norm(rod)) ./ degree;

plot(r,omega)

2*atan(norm(Rodrigues(rotation('axis',xvector,'angle',20*degree)))) ./ degree
