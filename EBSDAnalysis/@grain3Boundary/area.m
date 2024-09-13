function area = area(gB3,ind)
% calculates signed area of each face

if nargin == 2
  area = meshFaceAreas(gB3.allV.xyz, gB3.F(ind,:));
else
  area = meshFaceAreas(gB3.allV.xyz, gB3.F);
end

end