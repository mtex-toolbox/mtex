function peri = perimeter(g3B)
% calculates perimeter for each face
  V = g3B.allV.xyz;
  peri =  cellfun(@(ind) sum(sqrt(sum(diff(V(ind,:)).^2,2))),g3B.poly);
end