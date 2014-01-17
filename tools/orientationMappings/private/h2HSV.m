function [rgb,options] = h2HSV(h,cs,varargin)
% converts orientations to rgb values

options = extract_option(varargin,'antipodal');
varargin = delete_option(varargin,'complete');

% region to be plotted
[minTheta,maxTheta,minRho,maxRho] = cs.getFundamentalRegionPF(cs,varargin{:}); %#ok<ASGLU>
maxRho = maxRho - minRho;


% project to fundamental region
h = vector3d(h(:)); h = h./norm(h);
[sh,shAnti,pm] = h.project2FundamentalRegion(cs,varargin{:});

if check_option(varargin,'antipodal')
  switch Laue(cs)
  
    case '-1' %ok
    
      constraints = zvector;
      center = zvector;      
      maxRho = pi;
            
    case '2/m'
      
      constraints = cs(2).axis;
      center = constraints;
      maxRho = pi;
      shAnti = sh;
          
    case '-3'
      
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      
      
      % restrict fundamental region in black and white
      [theta,rho] = polar(shAnti);
      pm = rho > maxRho/2;
      rho(pm) = maxRho - rho(pm);
      shAnti = vector3d('polar',theta,rho);
      
      maxRho = 2*pi;
      
      warning('This colorcoding is not yet supported. Please use without option antipodal.')
      
    case {'4/m','6/m'} % ok
      
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      
      
      % restrict fundamental region in black and white
      [theta,rho] = polar(shAnti);
      pm = rho > maxRho/2;
      rho(pm) = maxRho - rho(pm);
      shAnti = vector3d('polar',theta,rho);
      
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
      [theta,rho] = polar(shAnti);
      pm = rho > pi/4;
      rho(pm) = pi/2 - rho(pm);
      shAnti = vector3d('polar',theta,rho);
      
    case '-3m' % ok
      
      constraints = [axis2quat(zvector,15*degree)*yvector,axis2quat(zvector,45*degree) * (-yvector),zvector];
      center = sph2vec(pi/4,30*degree);      
      
      
      % restrict fundamental region in black and white
      [theta,rho] = polar(shAnti);
      
      rho = rho - minRho;
      pm = rho > 45 * degree | rho < 15*degree;
      rho(rho>45*degree) = 90*degree-rho(rho>45*degree);
      rho(rho<15*degree) = 30*degree-rho(rho<15*degree);
      rho = rho + minRho;
      shAnti = vector3d('polar',theta,rho);
            
      maxRho = 2*pi;
      
    case {'mmm','4/mmm','6/mmm'} % ok
        
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
      
      rot = rotation(cs);      
      constraints = rot(2).axis;
      center = constraints;
      maxRho = pi;
      shAnti = sh;
      pm = dot(shAnti,center)>0;
      
    case 'm-3m'% ok
      
      constraints = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
      center = sph2vec(pi/6,pi/8);
      maxRho = 2*pi;
      
    case 'm-3' % ok
      
      minRho = -60*degree;
      maxRho = 120*degree;
      
      center = axis2quat(zvector,-minRho) * vector3d(1,1,1);
      constraints = axis2quat(zvector,-minRho) * [vector3d(1,0,0),vector3d(0,1,0)];
      
      
    case '-3m'
      
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      maxRho = 2*pi;

      [theta,rho] = polar(sh);
      
      rho = mod(rho - minRho,120*degree);
      pm = rho > 60 * degree;
      rho(pm) = 120*degree-rho(pm);
      rho = rho + minRho;
      shAnti = vector3d('polar',theta,rho);
                  
    case {'mmm','4/mmm','6/mmm'} % ok
    
      constraints = [yvector,axis2quat(zvector,maxRho/2) * (-yvector),zvector];
      center = sph2vec(pi/4,maxRho/4);      
      maxRho = 2*pi;
  end  
end

maxRho = maxRho + minRho;

% if the Fundamental region does not start at rho = 0
constraints = axis2quat(zvector,minRho) * constraints;
center = axis2quat(zvector,minRho) * center;

% maybe a custom center is given
center = get_option(varargin,'colorcenter',center);
center = project2FundamentalRegion(center./ norm(center),{cs},varargin{:});
options = [{'colorcenter',center},options];

% compute angle of the points "sh" relative to the center point "center"
omega = calcAngle(shAnti,center);
if maxRho-minRho < 2*pi-1e-5
  omega = mod(mod(omega-minRho,2*pi)./(maxRho-minRho),1);
else
  omega = mod(omega./2./pi,1);
end

% compute saturation
[radius,options] = calcRadius(shAnti,center,constraints,options,varargin{:});

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
S(isnan(S))=0;

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

% some test cases
% 
% cs1 = symmetry('-3m','x||a*')
%
% -> 2-fold axis is || y
% fundamental region should start at 90 degree
% ebsdColorbar(cs,'position',[50 50 950  451 ],'complete')
% annotate(Miller('polar',65*degree,40*degree,cs),'all')
%
% cs2 = symmetry('-3m','x||a')
% ebsdColorbar(cs2,'position',[50 50 950  451 ],'complete')
%
% now the antipodal case
%
% ebsdColorbar(cs1,'position',[50 50 950  451 ],'antipodal')
% ebsdColorbar(cs2,'position',[50 50 950  451 ],'antipodal','complete')
