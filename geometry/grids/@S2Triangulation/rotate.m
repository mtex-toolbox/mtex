function sT = rotate(sT, rot)
% rotate S2FunTri
   
sT.vertices = rotate(sT.vertices,rot);
sT.edges = rotate(sT.edges,rot);
       
end