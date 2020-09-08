function [ad,omega] = calcAngleDistribution(cs,varargin)
% compute the angle distribution of a uniform ODF for a crystal symmetry
%
% Syntax
%   [ad,omega] = calcAngleDistribution(cs1)
%   [ad,omega] = calcAngleDistribution(cs1,cs2)
%   [ad,omega] = calcAngleDistribution(cs1,omega)
%
% Input
%  cs -  @crystalSymmetry
%  omega - angle
%
% Output
%  ad - angle distribution
%  omega - angles
%
% Options
%  angle|threshold - distribution with the angles within  a threshold
%

oR = fundamentalRegion(cs,varargin{:});

if ~isempty(varargin) && isa(varargin{1},'symmetry')
  cs = union(cs,varargin{1});
  varargin(1) = [];
end

% use fundamental region for the computation
if cs.id == 0 ||  check_option(varargin,'oR')
  [ad,omega] = oR.calcAngleDistribution;
  return
end

% get range of rotational angles
if isempty(varargin) || ~isnumeric(varargin{1})
  omega = linspace(0,oR.maxAngle,300);
else
  % restrict omega
  omega = varargin{1};
  omega = omega(omega < oR.maxAngle + 1e-8);
end

%
nfold = cs.nfold;

% multiplier
xchi = ones(size(omega));

% start of region for the highest symmetry axis
xhn = tan(pi/2/nfold);

% magic number
rmag = tan(omega./2);

% explicite formulae
switch cs.LaueName
          
  case {'12/m1','2/m11','112/m','-3','4/m','6/m','C12'}
                    
    % first region  -> nfold axis is working
    ind = rmag > xhn;
    xchi(ind) = xhn ./rmag(ind);
        
  case {'mmm','-3m1','-31m','4/mmm','6/mmm','D12'}
   
    % first region -> nfold axis is working
    ind = rmag > xhn;
    xchi(ind) = xhn ./rmag(ind);
    
    % second region ->
    ind = rmag > 1.0;
    xchi(ind) = xchi(ind) + nfold * (1./rmag(ind)-1);
    
    % third region ->
    xedge = sqrt(1 + xhn^2);
    ind = rmag > xedge;
    
    alpha1 = acos(xhn ./ rmag(ind));
    alpha2 = acos(1 ./ rmag(ind));
    XS21 = S2(alpha1,alpha2, pi/2);
    XS22 = S2(alpha2,alpha2, pi/nfold);
    
    xchi(ind) = xchi(ind) + nfold * XS21./pi + nfold * XS22./2./pi;
    
  case 'm-3'

    % first region
    xh3 = sqrt(3) / 3;
    ind = rmag > xh3;
    xchi(ind) = 4 * xh3 ./ rmag(ind) - 3;
    
    % second region
    xedge = sqrt(2) / 2;
    ind = rmag > xedge;
    alpha = acos(xh3./rmag(ind));
    xchi(ind) = xchi(ind) + 3 * S2(alpha,alpha,acos(1/3)) ./ pi;
    
  case 'm-3m'

    % first region -> for fould axis active
    xh4 = sqrt(2) - 1;
    ind = rmag > xh4;
    xchi(ind) = 3 * xh4./rmag(ind) - 2;
    
    % secod region -> three fold axis active
    xh3 = sqrt(3) / 3;
    ind = rmag > xh3;
    xchi(ind) = xchi(ind) + 4 * (xh3./rmag(ind) -1);
    
    % third region ->
    xedge = 2 - sqrt(2);
    ind = rmag > xedge;
    alpha1 = acos(xh4./rmag(ind));
    alpha2 = acos(xh3./rmag(ind));
    S12 = S2(alpha1,alpha1,pi/2);
    S24 = S2(alpha1,alpha2,acos(xh3));
    xchi(ind) = xchi(ind) + 3*S12./pi + 6*S24./pi;
    
  case 'C3T'
    
    a = tan(pi/12);
    b = sqrt(1+2*a^2);
    c = tan(atan(b)/2);
    alpha = 1/b;
    beta = a/b;
    
    delta1 = acos(beta);
    delta2 = acos(beta*(2*alpha-beta));
    delta3 = acos(alpha.^2 - 2*beta^2);
    
    xh1 = a;
    xh2 = c;
    xh3 = sqrt(3)*a;
    xh4 = sqrt(a);
    xh5 = sqrt(5)*a;
        
    alpha1 = acos(xh1./rmag);
    alpha2 = acos(xh2./rmag);
    
    xchi = 4*pi*ones(size(omega));
    
    % subtract two times 6 fold axis
    ind = rmag > xh1;
    xchi(ind) = xchi(ind) - 2*S1(alpha1(ind));
    
    % subtract 8 times times 3 fold axis
    ind = rmag > xh2;
    xchi(ind) = xchi(ind) - 8*S1(alpha2(ind));
    
    % 12 times axis intersects 4 fold axis
    ind = rmag > xh3;
    xchi(ind) = xchi(ind) + ...
      8*S2(alpha1(ind),alpha2(ind),delta1) + 4*S2(alpha2(ind),alpha2(ind),delta3);
    
    % 4 times axes intersects each other
    ind = rmag > xh4;
    xchi(ind) = xchi(ind) + 4*S2(alpha2(ind),alpha2(ind),delta2);
        
    
  case 'C3O'
    
    a = tan(pi/12);
    b = sqrt(1+2*a^2);
    c = tan(atan(b)/2);
    alpha = 1/b;
    beta = a/b;
    
    delta1 = acos(beta);
    delta2 = acos(beta*(2*alpha-beta));
    delta3 = acos(alpha);
    delta4 = pi/2;
    
    xh1 = tan(pi/24);
    xh2 = tan(pi/8);
    xh3 = c;
    xh4 = sqrt(xh1^2+xh2^2);
    xh5 = sqrt(xh1^2+xh2^2 + xh1^2*xh2^2);
    xh6 = sqrt(a);
    xh7 = sqrt(a+xh1^2+a*xh1^2);
        
    alpha1 = acos(xh1./rmag);
    alpha2 = acos(xh2./rmag);
    alpha3 = acos(xh3./rmag);
        
    xchi = 4*pi*ones(size(omega));
    
    % subtract two times 12 fold axis
    ind = rmag > xh1;
    xchi(ind) = xchi(ind) - 2*S1(alpha1(ind));
    
    % subtract 4 times times 4 fold axis
    ind = rmag > xh2;
    xchi(ind) = xchi(ind) - 4*S1(alpha2(ind));
    
    % subtract 8 times times 3 fold axis
    ind = rmag > xh3;
    xchi(ind) = xchi(ind) - 8*S1(alpha3(ind));
    
    % 12 times axis intersects 4 fold axis
    ind = rmag > xh4;
    xchi(ind) = xchi(ind) + 8 * (S2(alpha1(ind),alpha2(ind),delta4) ...
      + S2(alpha2(ind),alpha3(ind),delta3) + S2(alpha1(ind),alpha3(ind),delta1));
    
    % subtract 4 times times 4 fold axis
    ind = rmag > xh5;
    xchi(ind) = xchi(ind) - ...
      8*S3(alpha1(ind),alpha2(ind),alpha3(ind),delta3,delta1,delta4);
    
    % 3 fold axes intersecting each other
    ind = rmag > xh6;
    xchi(ind) = xchi(ind) + 4*S2(alpha3(ind),alpha3(ind),delta2);

end

% compute output
ad = 2 * numSym(cs) * xchi .* sin(omega ./ 2).^2;
ad = ad ./ mean(ad);
ad(ad<0) = 0;

ang = get_option(varargin,{'angle','threshold'},[]);
if ~isempty(ang)
  ad(omega<ang)= 0;
  ad = pi*ad./mean(ad);
end


end

% ---------------------------------------------------------------------

function a = C( alpha,beta,gamma )
% the area of the spherical triangle
% alpha, beta, gamma - angles between vertices

a = acos((cos(gamma)-cos(alpha).*cos(beta))./sin(alpha)./sin(beta));

end


function a = S1(rho)
% the area of a spherical cap

a = 2*pi*(1-cos(rho));
end

function a = S2(rho1,rho2,xi)
% area of the intersection of two sperical caps
% rho1, rho - radii of the caps
% xi - dist between the centers of the caps

a = 2.0*(pi - C(rho1,rho2,xi) ...
  - cos(rho1).*C(xi,rho1,rho2) ...
  - cos(rho2).*C(rho2,xi,rho1));

end

function a = S3(rho1,rho2,rho3,xi1,xi2,xi3)
% area of intrtsection of three spherical caps
% rho1, rho2, rho3 - radii of the sperical caps
% xi1, xi2, xi3 - dist between the centers of the caps

a = -pi + (S2(rho1,rho2,xi3) + S2(rho2,rho3,xi1) + S2(rho3,rho1,xi2))./2 ...
  + cos(rho1)*C(xi2,xi3,xi1) ...
  + cos(rho2)*C(xi3,xi1,xi2) ...
  + cos(rho3)*C(xi1,xi2,xi3);
end