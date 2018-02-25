classdef S2Triangulation
% a class represeneting a triangulation on the sphere
  
  properties
    vertices = vector3d % 
    edges    = vector3d %
    
    T         % list of triangles
    midPoints % midPoint of each triangle
    A_V       % adjacency matrix of the vertices
    A_T       % adjacency matrix of the triangles
    neighbours % 
    antipodal = false;
  end
  
  methods
    
    function sT = S2Triangulation(n)      
      % initialize a spherical triangulation
      
      if nargin == 0, return; end
      sT.vertices = n;
      
      sT = sT.update;
     
    end
    
    function sT = update(sT)
      
      nV = length(sT.vertices);
      
      [x,y,z] = double(sT.vertices);
      T = convhull(x,y,z); %#ok<*PROP>
      nT = size(T,1);
      
      V = sT.vertices(T);

      sT.edges = normalize(cross(V(:,[2 3 1]),V(:,[3 1 2])));
            
      %sT.midPoints = cross(V(:,1)-V(:,2),V(:,2)-V(:,3));
      sT.midPoints = normalize(V(:,1) + V(:,2) + V(:,3));
      
      % adjacency matrix for the vertices
      % A(i,j) > 0 if the vertices i and j have a edge in common
      % A(i,j) and A(j,i) gives the ids of the attaching two triangles
      sT.A_V = sparse(T,circshift(T,-1,2),repmat((1:size(T,1)).',3,1),...
        nV,nV,nV*7);

      % next we want to generate a list of neigbours neighborId which is
      % order in the same way as sT.T, i.e., the triangle neighborId(k,1)
      % has with the triangle k the vertices sT.T(k,[2,3]) in common.
      %
      % sort order: 23, 13, 12
      %
      
      % adjacency matrix for the triangles
      
      Tid = repmat(1:nT,3,1);

      % incidency matrix vertices vs. triangles
      I_VTL = (sparse(T.',Tid,1, nV, nT)).';
      I_VTR = (sparse(T.',Tid,repmat(2.^(0:2).', 1, nT), nV, nT)).';

      % acceptable values 2+1,4+1,4+2
      % possible values 0,1,2,4
      A_T = (I_VTL * I_VTR.');
      A_T = A_T .* spfun(@(x) ismember(x,[3,5,6]),A_T);
      %A_T(A_T <= 2) = 0;
      %A_T(A_T == 4) = 0;
      %A_T(A_T == 7) = 0;

      [neighbours,~,value] = find(A_T);
      neighbours = reshape(neighbours,3,[]);
      value = reshape(value,3,[]);
      [~,id] = sort(value,1,'descend');
      id = id + 3*repmat(0:size(id,2)-1,3,1);
      
      sT.neighbours = neighbours(id);
      
      sT.T = T;
      
    end
       
    function sT = rotate(sT, rot)
   
      sT.vertices = rotate(sT.vertices,rot);
      sT.midPoints =  rotate(sT.midPoints,rot);
      
    end
    
  end
  
  methods (Static = true)
    
    function demo
      
      v = equispacedS2Grid('points',100);
      sT = S2Triangulation(v);
      
      plot(sT)
        
    end
    
    
    function check
      
      v = equispacedS2Grid('points',100);
      sT = S2Triangulation(v);
      
      p = vector3d.rand(10);
      id1 = sT.findTriangle(p)
      id2 = sT.findTriangle2(p)
      
      
    end
    
    
  end

end
  
