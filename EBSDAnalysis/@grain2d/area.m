function A = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Options
%  3d - use 3D algorithm
%
% Output
%  A  - list of areas (in measurement units)
%

if check_option(varargin,'3d') % 3d algorithm without loop

  allV = grains.allV.xyz;

  allV = allV([grains.poly{:}].',:);
  grainStart =  cumsum([1;cellfun(@numel,grains.poly)]);

  N = grains.N.xyz;

  A = polySgnArea3(allV,N,grainStart);

elseif 0 || isscalar(grains) & check_option(varargin,'3d')  % 3d algorithm with loop

  A = zeros(length(grains),1);
  poly = grains.poly;

  allV = grains.allV.xyz;
  N = grains.N.xyz;

  % signed area
  for i=1:length(grains)
    
    %A(i) = -dot(N, sum(cross(allV(poly{i}(2:end),:),...
    %  allV(poly{i}(1:end-1),:)))) / 2;

    A(i) = polySgnArea3(allV(poly{i},:),N);

  end

elseif 1 % 2d algorithm without loop

  V = grains.rot2Plane .* grains.allV;
  Vx = V.x([grains.poly{:}].');
  Vy = V.y([grains.poly{:}].');
  
  grainStart =  cumsum([1;cellfun(@numel,grains.poly)]);

  A = polySgnArea(Vx,Vy,grainStart);

else  % 2d algorithm
  
  A = zeros(length(grains),1);
  poly = grains.poly;

  V = grains.rot2Plane .* grains.allV;
  Vx = V.x;
  Vy = V.y;

  for ig = 1:length(poly)
    A(ig) = polySgnArea(Vx(poly{ig}),Vy(poly{ig}));
  end

end
