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
  % calculate the normal vector
  X1=V(1,:);
  X2=V(2,:);
  X3=V(3,:);
  nV=cross(X2-X1,X3-X1);
  nV=1/norm(nV)*nV;

  % calculate signed Area
  for i=1:length(poly)
    Ptlist=V(poly{i},:);
    a=sum(cross(Ptlist(2:end,:),Ptlist(1:end-1,:)));
    A(i)=dot(nV,a)/2;
    %A(i)=norm(a)/2;        % unsigned area
  end
end
