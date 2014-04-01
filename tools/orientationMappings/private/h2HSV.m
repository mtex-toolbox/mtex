function [rgb,options] = h2HSV(h,cs,varargin)
% converts orientations to rgb values

% antipodal symmetry is nothing else then going to the Laue group
if check_option(varargin,'antipodal'), cs = cs.Laue;end
  
% region to be colored
sR = cs.fundamentalSector;

% project to fundamental region
h_sR = h.project2FundamentalRegion(cs);
h = h_sR;

center = sR.center;

% symmetry dependent settings
% not working: 26, 23, 22, 21, 19, 18,
switch cs.id

  case 3
    
    center = getMinAxes(cs);
  
    % reduce fundamental sector for black-white colorcoding
    sR.N(2) = center; sR.alpha(2) = 0;
     
    % copy to the reduced sector
    ind = dot(h_sR,sR.N(2))<1e-5;
    h(ind) = reflection(sR.N(2)) * h(ind);
    
    
  case 5 % -2m
    
    % reduce fundamental sector for black-white colorcoding
    sR.N(2) = rotate(sR.N(2),90*degree);
     
    % copy to the reduced sector
    ind = dot(h_sR,sR.N(2))<1e-5;
    h(ind) = reflection(sR.N(2)) * h(ind);
    
    center = sR.center;
  
    
  case 11 % 32
    
    % reduce fundamental sector for black-white colorcoding
    sR = rotate(cs.Laue.fundamentalSector,30*degree);
    
    % copy to the reduced sector
    ind = dot(h_sR,sR.N(2))<1e-5;    
    h(ind) = reflection(sR.N(2)) * h(ind);
    
    ind = dot(h_sR,sR.N(3))<1e-5;    
    h(ind) = reflection(sR.N(3)) * h(ind);
    
    center = sR.center;
    
  case 13 % -3m
        
    % reduce fundamental sector for black-white colorcoding
    sR.N(2) = rotate(sR.N(2),30*degree);
     
    % copy to the reduced sector
    ind = dot(h_sR,sR.N(2))<1e-5;
    h(ind) = reflection(sR.N(2)) * h(ind);
    
    center = sR.center;
  
  case 12
    
    sR = sR.restrict2Upper;
    % copy to the reduced sector
    ind = dot(h_sR,zvector)<1e-5;
    h(ind) = reflection(zvector) * h(ind);
    
    center = sR.center;
     
  case 15 % impossible
    
    % reduce fundamental sector for black-white colorcoding
    sR.N(2) = rotate(sR.N(2),90*degree);
     
    % copy to the reduced sector
    ind = dot(h_sR,sR.N(2))<1e-5;
    h(ind) = reflection(sR.N(2)) * h(ind);
    
    center = sR.center;
    
  case {1,6,7,17,24,25,26,30,31,19}
    
    % restrict to the fundamental region of the corresponding Laue class
    % and colorize one center to black and the other to white
    sR = cs.Laue.fundamentalSector;
    h = h_sR.project2FundamentalRegion(cs.Laue);
    center = sR.center;
    
  case 28 % 23
    
    sR = cs.Laue.fundamentalSector;
    h = h_sR.project2FundamentalRegion(cs.Laue);    
    center = vector3d(1,1,1);
    
  case 29 % m-3
    
    sym = symmetry('m-3m');
    sR = sym.fundamentalSector;
    h = h_sR.project2FundamentalRegion(sym);
    center = sR.center;
    
  case {9,14,16,21,22,23}
    
    sR = sR.restrict2Upper;
    % copy to the reduced sector
    ind = dot(h_sR,zvector)<1e-5;
    h(ind) = reflection(zvector) * h(ind);
    
    center = zvector;
        
    
    
end
  
% compute angle of the points "sh" relative to the center point "center"
% this should be between 0 and 1
[radius,rho] = polarCoordinates(sR,h,center);

% which are white
whiteOrBlack = h_sR == h;

% white center
radius(whiteOrBlack) = 0.5+radius(whiteOrBlack)./2;

% black center
radius(~whiteOrBlack) = (1-radius(~whiteOrBlack))./2;

v = vector3d('rho',rho,'theta',radius.*pi);

% symmetry dependent settings
switch cs.id

  
  case {1}
    rho(~whiteOrBlack) = mod(pi + rho(~whiteOrBlack),2*pi);
    v = vector3d('rho',rho,'theta',radius.*pi);
  case {28}
    %rho = mod(3*rho,2*pi);
    
  case {3,9,14,21}
    
    v = rotate(v,axis2quat(yvector,-pi/2));
    
end


% compute rgb values
rgb = ar2rgb(mod(v.rho./ 2 ./ pi,1),v.theta./pi,get_option(varargin,'grayValue',1));

options = {};

end

% some testing code
% cs = symmetry('m-3m')
% h = plotS2Grid(cs.fundamentalSector)
% rgb = h2HSV(h,cs);
% surf(h,rgb)

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

