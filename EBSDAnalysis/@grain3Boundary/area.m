function area = area(gB3,ind)
% calculates signed area of each face

% TODO: why should this be the signed 


if iscell(gB3.F)

  allV = gB3.allV.xyz;

  if nargin == 2
    allV = allV([gB3.F{ind}].',:);
    grainStart =  cumsum([1;cellfun(@numel,gB3.F(ind))]);
    N = gB3.N(ind).xyz;
  else
    allV = allV([gB3.F{:}].',:);
    grainStart =  cumsum([1;cellfun(@numel,gB3.F)]);
    N = gB3.N.xyz;
  end
  
  area = polySgnArea3(allV,N,grainStart);

else  % triangulated boundary

  allV = gB3.allV.xyz;

  if nargin == 2
    e12 = allV(gB3.F(ind,2),:) - allV(gB3.F(ind,1),:);
    e13 = allV(gB3.F(ind,3),:) - allV(gB3.F(ind,1),:);
  else
    e12 = allV(gB3.F(:,2),:) - allV(gB3.F(:,1),:);
    e13 = allV(gB3.F(:,3),:) - allV(gB3.F(:,1),:);
  end
  area = vecnorm(cross(e12,e13),2,2)./2;

end

end
