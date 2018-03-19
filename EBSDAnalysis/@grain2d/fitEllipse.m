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

% extract vertices
Vin = grains.V;

omega=zeros(length(grains),1); a=omega; b=omega;

for i = 1:length(grains)

  % extract vertices of ith grains
  V= Vin(grains.poly{i},:); 

  % center vertices
  V = V - repmat(mean(V,1),size(V,1),1);

  % get 2nd moments of area
  [omega(i),ew] = eig2(V.' * V,'angle');
  a(i) = sqrt(ew(1)); b(i) = sqrt(ew(2));

end

% compute scaling
if check_option(varargin,'boundary') % boundary length fit
  [~,E] = ellipke(sqrt((a.^2 - b.^2)./a.^2));
  scaling = grains.perimeter ./ a ./4 ./ E;
else % area fit
  scaling = sqrt(grains.area ./ a ./ b ./pi);
end

% scale halfwidth
a = a.*scaling; b = b.*scaling;

end
