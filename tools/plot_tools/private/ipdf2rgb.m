function c = ipdf2rgb(h,cs,varargin)
% converts orientations to rgb values


%% fundamental region

[maxtheta,maxrho,minrho] = getFundamentalRegionPF(cs,varargin{:});
maxrho = maxrho - minrho;
h = vector3d(h); h = h./norm(h);
switch Laue(cs)
  
  case {'-1','2/m','-3','4/m','6/m'}
    if check_option(varargin,'axial')
      h(getz(h)<0) = -h(getz(h)<0);
    end
    [theta,rho] = polar(h(:));
    rho = mod(rho,maxrho)./maxrho;
    pm = theta(:) >= pi/2;
    c(pm,:) = hsv2rgb([rho(pm),ones(sum(pm),1),2-theta(pm)./pi*2]);
    c(~pm,:) = hsv2rgb([rho(~pm),theta(~pm)./pi*2,ones(sum(~pm),1)]);
    c = reshape(c,[size(h),3]);
    return
  case 'm-3m'
    constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
    constraints = constraints ./ norm(constraints);
    center = sph2vec(pi/6,pi/8); 
  case 'm-3'
    if ~check_option(varargin,'axial')
      warning('For symmetry ''m-3'' only axial colorcoding is supported right now'); %#ok<WNTAG>
    end
    
    varargin = delete_option(varargin,'axial');
    cs = symmetry('m-3m');
    constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
    constraints = constraints ./ norm(constraints);
    center = sph2vec(pi/6,pi/8);
    
  otherwise
    
    if check_option(varargin,'axial'), maxrho = maxrho * 2;end
    constraints = [yvector,axis2quat(zvector,maxrho/2) * (-yvector),zvector];
    %constraints = [-axis2quat(zvector,-maxrho/2) * yvector];
    center = sph2vec(pi/4,maxrho/4);
end

[sh,pm,rot] = project2FundamentalRegion(vector3d(h),cs,varargin{:});

% if the Fundamental region does not start at rho = 0
constraints = axis2quat(zvector,rot) * constraints;
center = axis2quat(zvector,rot) * center;


%% compute angle
rx = center - zvector; rx = rx ./ norm(rx);
ry = cross(center,rx); ry = ry ./ norm(ry);
dv = (center - sh); dv = dv ./ norm(dv);
omega = mod(atan2(dot(rx,dv),dot(ry,dv))-pi/2,2*pi);
omega(isnan(omega)) = 0;
omega = omega(:);


%% compute saturation

% center
center = get_option(varargin,'colorcenter',center);
center = project2FundamentalRegion(center./ norm(center),cs,varargin{:});
cc = cross(sh,center);
cc = cc ./ norm(cc);

if check_option(varargin,'radius') % linear interpolation to the radius
  
  radius = get_option(varargin,'radius',1);
  dh(:,:) = 1-min(1,angle(sh,center)./radius);
  
else % linear interpolation to the boundaries
  
  dh = zeros([size(sh),length(constraints)]);
  for i = 1:length(constraints)
    
    % boundary points
    bc = cross(cc,constraints(i));
    bc = bc ./ norm(bc);

    % compute distances
    dh(:,:,i) = angle(-sh,bc)./angle(-center,bc);
    dh(isnan(dh)) = 1;
  end
  dh = min(dh,[],3);
end

dh(imag(dh) ~=0 ) = 0;
dh = dh(:);


%% compute colors
c = zeros(numel(h),3);
if any(pm), c(pm,:) = hsv2rgb([omega(pm)./2./pi,ones(sum(pm),1),1-dh(pm)]);end
if ~all(pm), c(~pm,:) = hsv2rgb([omega(~pm)./2./pi,1-dh(~pm),ones(sum(~pm),1)]);end
%c = reshape(c,[size(h),3]);

