function [omega,a,b] = fitEllipse(grains,varargin)
% fit ellipses to grains using the method described in Mulchrone&
% Choudhury,2004 (https://doi.org/10.1016/S0191-8141(03)00093-2)
% 
% Syntax
%
%   [omega,a,b] = principalComponents(grains);
%   plotEllipse(grains.centroid,a,b,omega,'lineColor','r')
%
% Input:
%  grains   - @grain2d
%
% Output:
%  omega    - angle  giving trend of ellipse long axis
%  a        - long axis radius
%  b        - short axis radius
% 
% Options:
%  hull     - use convex hull to fit ellipse
%

Vin=grains.V; % sort of carries on ALL! V

omega=zeros(length(grains),1);
a=omega;
b=omega;

% todo: get rid of that loop
%       scale to boundary length

for i = 1:length(grains)

V= Vin(grains.poly{i},:); % vertices of ith grains

if check_option(varargin,'hull')
    %use hull
    ind = convhulln(V);
    V = V(ind(:,1),:);
end

n=size(V,1);

% get centers and 2nd moments of area
xb= sum(V(:,1))/n;
yb= sum(V(:,2))/n;

u20=sum((V(:,1)-xb).^2)/n;
u02=sum((V(:,2)-yb).^2)/n;
u11=abs(sum( (V(:,1)-xb).*(V(:,2)-yb) )/n); % since this can be negative
                                            % but we like real angles

                                            % directions
omega(i)= 0.5*atan(2*u11/(u20-u02));
% axes; - eigenvalues of [u20 u11; u11 u02]
a(i)=sqrt(2*( u20+u02+sqrt(4*u11^2+(u20-u02).^2 ))/u11);
b(i)=sqrt(2*( u20+u02-sqrt(4*u11^2+(u20-u02).^2 ))/u11);

end

% scale to area
areaElli= pi.*a.*b;
scalef= sqrt(grains.area./areaElli);

a = a.*scalef;
b = b.*scalef;

end