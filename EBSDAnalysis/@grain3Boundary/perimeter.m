function peri = perimeter(g3B)
% calculates perimeter for each face

if iscell(g3B.F)
  V = g3B.allV.xyz;
  peri =  cellfun(@(ind) sum(sqrt(sum(diff(V(ind,:)).^2,2))),g3B.F);
else  % faster for triangulated meshes

  assert(size(g3B.F,2)==3);

  Faces = [g3B.F(:,:) g3B.F(:,1)];
  
  VArray = g3B.allV(Faces);
  VArray = reshape(VArray',1,[])';
  
  parts = sqrt(sum(diff(VArray.xyz).^2,2));
  
  ind = repelem((1:size(Faces,1))',3);
  b = repmat([true(3,1);false],size(Faces,1),1);
  peri = accumarray(ind,parts(b));
end
end