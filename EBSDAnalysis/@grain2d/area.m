function A = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Output
%  A  - list of areas (in measurement units)
%

poly = grains.poly;
V = grains.V;
A = zeros(length(poly),1);

if (size(V,2)==2)        % plane in 2d
  for ig = 1:length(poly)
    A(ig) = polySgnArea(V(poly{ig},1),V(poly{ig},2));
  end
elseif (size(V,2)==3)    % plane in 3d 
  nV=grains.N.xyz;
  % calculate signed Area
  for i=1:length(poly)
    Ptlist=V(poly{i},:);
    a=sum(cross(Ptlist(2:end,:),Ptlist(1:end-1,:)));
    A(i)=dot(nV,a)/2;
    %A(i)=norm(a)/2;        % unsigned area
  end
end
