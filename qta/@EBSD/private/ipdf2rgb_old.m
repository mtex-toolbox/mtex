function c = ipdf2rgb(h,cs,varargin)
% converts orientations to rgb values

% compute colors
[maxtheta,maxrho] = getFundamentalRegionPF(cs,varargin{:});

if check_option(varargin,'axial'), maxrho = maxrho * 2;end

h = vector3d(h);
switch Laue(cs)
  
  case '-1'
    if check_option(varargin,'axial')
      h(getz(h)<0) = -h(getz(h)<0);
    end
    [theta,rho] = polar(h);
    rho = mod(rho,2*pi);
    pm = theta(:) >= pi/2;
    c(pm,:) = hsv2rgb([rho(pm)./2./pi,ones(sum(pm),1),2-theta(pm)./pi*2]);
    c(~pm,:) = hsv2rgb([rho(~pm)./2./pi,theta(~pm)./pi*2,ones(sum(~pm),1)]);
    c = reshape(c,[size(h),3]);
    return
  case 'm-3m'
    r1 = yvector;
    r2 = vector3d(1,-1,0) ./ norm(vector3d(1,-1,0));
    r3 = vector3d(-1,0,1) ./ norm(vector3d(-1,0,1));    
  otherwise
    r1 = yvector;
    r2 = axis2quat(zvector,maxrho/2) * yvector;
    r3 = zvector;
end


sh = cs * h;

% compute bayozentric coordinates
[theta,rho] = polar(sh);
rho = mod(rho,2*pi);
d1 = rho + 1000*theta;
[d1,sh1] = selectMinbyColumn(d1,sh);

[theta,rho] = polar(-sh);
rho = mod(rho,2*pi);
d2 = rho + 1000*theta;
[d2,sh2] = selectMinbyColumn(d2,-sh);

if check_option(varargin,'axial')
  pm = false(numel(h),1);
else
  pm = d1 > d2;
end
[d,sh] = selectMinbyRow([d1,d2],[sh1,sh2]);


% compute distances
dx = abs(dot_outer(sh,r1));
dy = abs(dot_outer(sh,r2));
dz = abs(dot_outer(sh,r3));

% compute angle
v = axis2quat(zvector,(0:120:240)*degree) * (-xvector);
r = dx * v(1) + dy * v(2) + dz * v(3);
[th,rh] = vec2sph(r);

maxd = max([dx,dy,dz],[],2);
mind = min([dx,dy,dz],[],2);

c = zeros(numel(h),3);
c(pm,:) = hsv2rgb([0.5+rh(pm)./2./pi,ones(sum(pm),1),1-mind(pm)./maxd(pm)]);
c(~pm,:) = hsv2rgb([0.5+rh(~pm)./2./pi,1-mind(~pm)./maxd(~pm),ones(sum(~pm),1)]);
c = reshape(c,[size(h),3]);

