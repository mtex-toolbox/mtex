function area = area(gB3)
% calculates signed area of each face
  area = meshFaceAreas(gB3.allV.xyz, gB3.poly);
end