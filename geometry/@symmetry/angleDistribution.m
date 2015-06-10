function [ad,omega] = angleDistribution(cs,varargin)
% compute the angle distribution of a uniform ODF for a crystal symmetry
%
% Syntax
%   [ad,omega] = angleDistribution(cs1)
%   [ad,omega] = angleDistribution(cs1,cs2)
%   [ad,omega] = angleDistribution(cs1,omega)
%
% Input
%  cs - crystal @symmetry
%  omega - angle
%
% Ouput
%  ad - angle distribution
%  omega - angles
%
% Options
%  angle|threshold - distribution with the angles within  a threshold
%

% better TODO!!!!
oR = fundamentalRegion(cs,varargin{:});
% [ad,omega] = oR.angleDistribution(varargin{:});

if ~isempty(varargin) && isa(varargin{1},'symmetry')
  
  % TODO: This is not correct
  % cs = union(cs,varargin{1});
  if length(cs) <  length(varargin{1})
    cs = varargin{1};
  end
  varargin(1) = [];
  
end

if isempty(varargin)
  omega = linspace(0,oR.maxAngle,300);
else
  % restrict omega
  omega = varargin{1};
  omega = omega(omega < oR.maxAngle + 1e-8);
end

% multiplier
xchi = ones(size(omega));

% start of region for the highest symmetry axis
xhn = tan(pi/2/cs.nfold);

% magic number
rmag = tan(omega./2);

switch cs.LaueName
          
  case {'12/m1','2/m11','112/m','-3','4/m','6/m'}
                    
    % first region  -> nfold axis is working
    ind = rmag > xhn;
    xchi(ind) = xhn ./rmag(ind);
        
  case {'mmm','-3m1','-31m','4/mmm','6/mmm'}
   
    % first region -> nfold axis is working
    ind = rmag > xhn;
    xchi(ind) = xhn ./rmag(ind);
    
    % second region ->
    ind = rmag > 1.0;
    xchi(ind) = xchi(ind) + cs.nfold*(1./rmag(ind)-1);
    
    % third region ->
    xedge = sqrt(1 + xhn^2);
    ind = rmag > xedge;
    
    alpha1 = acos(xhn ./ rmag(ind));
    alpha2 = acos(1 ./ rmag(ind));
    XS21 = S2ABC(alpha1,alpha2,pi/2);
    XS22 = S2ABC(alpha2,alpha2,pi/cs.nfold);
    
    xchi(ind) = xchi(ind) + cs.nfold*XS21./pi + cs.nfold*XS22./2./pi;
    
  case 'm-3'

    % first region
    xh3 = sqrt(3) / 3;
    ind = rmag > xh3;
    xchi(ind) = 4 * xh3 ./ rmag(ind) - 3;
    
    % second region
    xedge = sqrt(2) / 2;
    ind = rmag > xedge;
    alpha = acos(xh3./rmag(ind));
    xchi(ind) = xchi(ind) + 3 * S2ABC(alpha,alpha,acos(1/3)) ./ pi;
    
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
    S12 = S2ABC(alpha1,alpha1,pi/2);
    S24 = S2ABC(alpha1,alpha2,acos(xh3));
    xchi(ind) = xchi(ind) + 3*S12./pi + 6*S24./pi;
        
end

% compute output
ad = 2 * length(cs) * xchi .* sin(omega ./ 2).^2;
ad = ad ./ mean(ad);
ad(ad<0) = 0;

ang = get_option(varargin,{'angle','threshold'},[]);
if ~isempty(ang)
  ad(omega<ang)= 0;
  ad = pi*ad./mean(ad);
end


end

function C = C2ABC( alpha,beta,gamma )

C = acos((cos(gamma)-cos(alpha).*cos(beta))./sin(alpha)./sin(beta));

end

function S2 = S2ABC(alpha,beta,gamma )

C1 = C2ABC(alpha,beta,gamma);
C2 = C2ABC(gamma,alpha,beta);
C3 = C2ABC(beta,gamma,alpha);
S2 = 2.0*(pi-C1-cos(alpha).*C2-cos(beta).*C3);

end
