classdef grain3Boundary < phaseList & dynProp

  properties  % with as many rows as data
    id = []
    poly  % cell arry with all faces
  end
  
  properties
    idV      % ids of the used verticies ?
    allV     % verticies
  end

  properties (Dependent)
    V
    faceNormals
    faceCentroids
  end

  methods

    function gB = grain3Boundary(V,poly)
      
      if isa(V, 'vector3d')

      elseif (isnumeric(V) && (size(V,2)==3))
        V=vector3d(V)';
      else
        error 'invalid V'
      end

      gB.allV = V;
      gB.idV = (1:length(V))';
      gB.poly = poly;
      gB.id = (1:length(poly))';
      
    end

    function V = get.V(gB3)
      V = gB3.allV(gB3.idV);
    end

    function gB3 = set.V(gB3,V)
      gB3.allV = V;
    end

    function normals = get.faceNormals(gB3)
      normals = vector3d(meshFaceNormals(gB3.allV.xyz, gB3.poly))';
    end

    function centroids = get.faceCentroids(gB3)
      centroids = vector3d(meshFaceCentroids(gB3.allV.xyz, gB3.poly))';
    end

  end

end