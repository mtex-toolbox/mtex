function c = ipdf2rgb(h,cs,varargin)
% converts orientations to rgb values

% compute colors
[maxtheta,maxrho] = getFundamentalRegionPF(cs,varargin{:});

if check_option(varargin,'reduced'), maxrho = maxrho * 2;end

h = vector3d(h); h = h./norm(h);
switch Laue(cs)
  
  case '-1'
    if check_option(varargin,'reduced')
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
    %r1 = yvector;
    %r2 = vector3d(1,-1,0) ./ norm(vector3d(1,-1,0));
    %r3 = vector3d(-1,0,1) ./ norm(vector3d(-1,0,1));    
    constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
    constraints = constraints ./ norm(constraints);
    center = sph2vec(pi/6,pi/8); 
  otherwise
    constraints = [yvector,axis2quat(zvector,maxrho/2) * (-yvector),zvector];
    %constraints = [-axis2quat(zvector,-maxrho/2) * yvector];
    center = sph2vec(pi/4,maxrho/4);
end

center = get_option(varargin,'colorcenter',center);
center = center ./ norm(center);

sh = cs * h;

[theta,rho] = polar(sh);
rho = mod(rho,2*pi);
d1 = rho + 1000*theta;
[d1,sh1] = selectMinbyColumn(d1,sh);

[theta,rho] = polar(-sh);
rho = mod(rho,2*pi);
d2 = rho + 1000*theta;
[d2,sh2] = selectMinbyColumn(d2,-sh);

if check_option(varargin,'reduced')
  pm = false(numel(h),1);
else
  pm = d1 > d2;
end
[d,sh] = selectMinbyRow([d1,d2],[sh1,sh2]);


%% compute saturdation

% center
cc = cross(sh,center);
cc = cc ./ norm(cc);

dh = zeros([size(sh),length(constraints)]);
for i = 1:length(constraints)
  
  % boundary points
  bc = cross(cc,constraints(i));
  bc = bc ./ norm(bc);

  % compute distances
  %dh = acos(max(dot(-hv,bc),dot(hv,bc)));
  dh(:,:,i) = acos(dot(-sh,bc))./acos(dot(-center,bc));
end

dh = min(dh,[],3);
dh(imag(dh) ~=0 ) = 0;

%% compute angle

rx = center - zvector; rx = rx ./ norm(rx);
ry = cross(center,rx); ry = ry ./ norm(ry);
dv = (center - sh); dv = dv ./ norm(dv);

omega = mod(atan2(dot(rx,dv),dot(ry,dv))-pi/2,2*pi);

c = zeros(numel(h),3);
c(pm,:) = hsv2rgb([omega(pm)./2./pi,ones(sum(pm),1),1-dh(pm)]);
c(~pm,:) = hsv2rgb([omega(~pm)./2./pi,1-dh(~pm),ones(sum(~pm),1)]);
c = reshape(c,[size(h),3]);

