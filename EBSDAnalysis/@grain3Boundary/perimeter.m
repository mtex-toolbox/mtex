function peri = perimeter(g3B)
% calculates perimeter for each face

if iscell(g3B.poly)
  V = g3B.allV.xyz;
  peri =  cellfun(@(ind) sum(sqrt(sum(diff(V(ind,:)).^2,2))),g3B.poly);
else  % faster for triangulated meshes

  assert(size(g3B.poly,2)==3);

  Poly = [g3B.poly(:,:) g3B.poly(:,1)];
  
  VArray = g3B.allV(Poly);
  VArray = reshape(VArray',1,[])';
  
  parts = sqrt(sum(diff(VArray.xyz).^2,2));
  
  ind = repelem((1:size(Poly,1))',3);
  b = repmat([true(3,1);false],size(Poly,1),1);
  peri = accumarray(ind,parts(b));
end
end