function res = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Output
%  A  - list of areas (in measurement units)
%

res = zeros(length(grains.poly),1);

poly = grains.poly;
V = grains.V;

dim=size(V);
dim=dim(2);
switch dim
  case 3
    % rotate the 2dslice into xy-plane (z becomes zero)
    A=V(1,:);
    B=V(2,:);
    C=V(3,:);
    
    v1=B-A;
    v2=C-A;
    z=[0,0,1];
    
    n=cross(v1,v2);
    n=1/norm(n)*n;
    
    if (n~=[0,0,1])
      rot_angle=-asind(norm(cross(n,z))/(norm(n)*norm(z)));
      rot_angle=rot_angle/360*2*pi;
      rot_axis=cross(n,z);
      rot_axis=1/norm(rot_axis)*rot_axis;
      
      R=rotation.byAxisAngle(vector3d(rot_axis),rot_angle);
      
      Vrot=zeros(total_number_of_vertices,3);
      for i=1:total_number_of_vertices
        buffer=R*vector3d(V(i,:));
        Vrot(i,:)=buffer.xyz;
      end
      V=Vrot-[0,0,Vrot(1,3)];
    end
    
    for i=1:length(V)
      if V(i,3)~=0
        error('Error: vertices not in plane')
      end
    end

    V=V(:,1:2);
    
  case 2

  otherwise
    error ('dimension is %s not 2 or 3', num2str(dim))
end

%calculate area
for ig = 1:length(poly)
  res(ig) = polySgnArea(V(poly{ig},1),V(poly{ig},2));
end
