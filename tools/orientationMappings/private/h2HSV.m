function [rgb,options] = h2HSV(h,cs,varargin)
% converts orientations to rgb values

options = extract_option(varargin,'antipodal');
varargin = delete_option(varargin,'complete');

[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(cs,varargin{:}); %#ok<ASGLU>
maxRho = maxRho - minRho;

% project to fundamental region
h = vector3d(h(:)); h = h./norm(h);
[sh,pm,rho_min] = project2FundamentalRegion(vector3d(h),{cs},varargin{:});

if check_option(varargin,'antipodal')
  switch Laue(cs)
  
    case '-1' %ok
    
      constraints = zvector;
      center = zvector;      
      maxRho = pi;
            
    case '2/m' %ok
      
      rot = get(cs,'rotation');      
      constraints = get(rot(2),'axis');
      center = constraints;
      maxRho = pi;
      
    case {'-3','4/m','6/m'} % ok
      
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      
      
      % restrict fundamental region in black and white
      [theta,rho] = polar(sh);
      pm = rho > maxRho/2;
      rho(pm) = maxRho - rho(pm);
      sh = vector3d('polar',theta,rho);
      
      maxRho = 2*pi;
      
    case 'm-3m' % ok
      
      constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
      center = sph2vec(pi/6,pi/8);
      maxRho = 2*pi;
      
    case 'm-3' % ok
      
      constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
      center = sph2vec(pi/6,pi/8);
      maxRho = 2*pi;

      % restrict fundamental region in black and white
      [theta,rho] = polar(sh);
      pm = rho > pi/4;
      rho(pm) = pi/2 - rho(pm);
      sh = vector3d('polar',theta,rho);
      
    case {'mmm','-3m','4/mmm','6/mmm'} % ok
        
      constraints = [yvector,axis2quat(zvector,maxRho) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/2);
      maxRho = 2*pi;

  end

else
  
  switch Laue(cs)
         
    case {'-1','-3','4/m','6/m'} % ok
      
      constraints = zvector;      
      center = zvector;      
    
    case '2/m' %ok
      
      rot = get(cs,'rotation');      
      constraints = get(rot(2),'axis');
      center = constraints;
      maxRho = pi;
      
    case 'm-3m'% ok
      
      constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
      center = sph2vec(pi/6,pi/8);
      maxRho = 2*pi;
      
    case 'm-3' % ok
      
      center = vector3d(1,1,1);
      constraints = [vector3d(1,0,0),vector3d(0,1,0)];
      minRho = -60*degree;
      maxRho = 120*degree;
      
    case {'mmm','-3m','4/mmm','6/mmm'} % ok
    
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      maxRho = 2*pi;
  end  
end

maxRho = maxRho + minRho;

% if the Fundamental region does not start at rho = 0
constraints = axis2quat(zvector,rho_min) * constraints;
center = axis2quat(zvector,rho_min) * center;

% maybe a custom center is given
center = get_option(varargin,'colorcenter',center);
center = project2FundamentalRegion(center./ norm(center),{cs},varargin{:});
options = [{'colorcenter',center},options];

% compute angle of the points "sh" relative to the center point "center"
omega = calcAngle(sh,center);
omega = mod(mod(omega-minRho,2*pi)./(maxRho-minRho),1);

% compute saturation
[radius,options] = calcRadius(sh,center,constraints,options,varargin);

% black center
radius(pm) = (1-radius(pm))./2;

% white center
radius(~pm) = 0.5+radius(~pm)./2;

% compute rgb values
rgb = ar2rgb(omega,radius,get_option(varargin,'grayValue',1));

end

% ---------------------------------------------------------------------
% compute rgb values from angle and radius
% ---------------------------------------------------------------------
function rgb = ar2rgb(omega,radius,grayValue)


L = (radius - 0.5) .* grayValue(:) + 0.5;

S = grayValue(:) .* (1-abs(2*radius-1)) ./ (1-abs(2*L-1));


[h,s,v] = hsl2hsv(omega,S,L);

rgb = hsv2rgb(h,s,v);

end

% -------------------------------------------------------------------
% compute the relative distance to center in a spherical triangle
% -------------------------------------------------------------------
function [r,options] = calcRadius(sh,center,constraints,options,varargin)

% linear interpolation to the radius
if check_option(varargin,'radius') 
  
  radius = get_option(varargin,'radius',1);
  dh(:,:) = 1-min(1,angle(sh,center)./radius);
  options = [options,{'radius',radius}];

elseif quantile(angle(sh,center),0.9) < 10*degree
  
  radius = quantile(angle(sh,center),0.9);
  dh(:,:) = 1-min(1,angle(sh,center)./radius);
  options = [options,{'radius',radius}];
  
else % linear interpolation to the boundaries
  
  cc = cross(sh,center);
  cc = cc ./ norm(cc);
  
  dh = zeros([size(sh),length(constraints)]);
  constraints = constraints ./ norm(constraints);
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
r = dh(:);

end

%------------------------------------------------------------------------
% compute the angle of points "v" relative to a center "center"
%------------------------------------------------------------------------
function omega = calcAngle(v,center)

center = center ./ norm(center);
if center == zvector %#ok<BDSCI>
  rx = xvector - center; 
else
  rx = zvector - center;
end
rx = rx - dot(rx,center) .* center;
rx = rx ./ norm(rx);
ry = cross(center,rx); 
ry = ry ./ norm(ry);

dv = (v - center); 
dv = dv ./ norm(dv);

omega = mod(atan2(dot(ry,dv),dot(rx,dv)),2*pi);
omega(isnan(omega)) = 0;
omega = omega(:);

end