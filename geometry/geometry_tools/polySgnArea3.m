function area = polySgnArea3(xyz,N,grainStart)
% signed polygon area 
%
% Syntax
%
%   area = polySgnArea3(xyz,N,grainStart)
%
% Input
%

cxyz = cross(xyz(2:end,:),xyz(1:end-1,:),2);

if nargin == 3

  ind = repelem(1:length(grainStart)-1,diff(grainStart)).';
  
  % set the value for last entry of each loop to zero
  cxyz(grainStart(2:end)-1,:) = 0;
  
  cx = accumarray(ind,cxyz(:,1));
  cy = accumarray(ind,cxyz(:,2));
  cz = accumarray(ind,cxyz(:,3));

  area = -0.5 * (cx .* N(:,1) + cy .* N(:,2) + cz .* N(:,3));
  
else

  area = -dot(N, sum(cxyz,1)) / 2;
  
end

end
