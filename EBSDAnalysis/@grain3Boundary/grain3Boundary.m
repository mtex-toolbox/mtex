classdef grain3Boundary < phaseList & dynProp

  properties  % with as many rows as data
    id = []
    poly                  % cell arry with all faces
    grainId = zeros(0,2)  % id's of the neigbouring grains to a face
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

    function gB = grain3Boundary(V, poly, grainId, phaseId, CSList, phaseMap)
      
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
      gB.grainId = grainId;

      gB.phaseId = zeros(size(grainId));
      b = find(grainId(:,1));
      gB.phaseId(b,1) = phaseId(grainId(b,1));
      b = find(grainId(:,2));
      gB.phaseId(b,2) = phaseId(grainId(b,2));

      gB.CSList = CSList;
      gB.phaseMap = phaseMap;
      
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