classdef crystalShape 
  
  
  properties
    N % face normals
    V % vertices
    F % faces
  end
  
  properties (Dependent = true)
    CS % crystal symmetry
  end
  
  methods
    
    function cS = crystalShape(N)
      
      if isa(N,'crystalSymmetry')
        N = basicHKL(cs);
        N = N .* N.dspacing;
      else
        N = unique(N.symmetrise,'noSymmetry');
      end
      cS.N = N;
      
      cS = cS.update;
    end
        
    function cS = update(cS)

      % ensure N is vector3d
      N = vector3d(cS.N); %#ok<*PROP>
      tol = 1e-5;

      % compute vertices as intersections between all combinations
      % of three planes
      [a,b,c] = allTriple(1:length(N));
      V = planeIntersect(N(a),N(b),N(c));

      % take only the finite ones
      V = V(V.isfinite);

      % take only those inside the polyhedron
      V = V(all(dot_outer(V,N) <= 1 + tol,2));
      V = unique(V);

      % convert to double
      N = squeeze(double(N(:)));
      
      % triangulation
      DT = delaunayTriangulation(squeeze(double(V)));
      [FBtri,V] = freeBoundary(DT);
      TR = triangulation(FBtri,V);
      FE = featureEdges(TR,1e-5)';
      
      % preallocate face list
      F = nan(length(N),length(N));
      
      % for all potential faces
      for a = 1:length(N)
        
        % which vertices belong to face a ?
        B = find(V * N(a,:).' > 1-tol).';
        
        % which featureEdges belong to face a ?
        A = FE(:,all(ismember(FE,B)));
        
        % conect edges to form a polygon
        face = cell2mat(EulerCycles(A.'));
        F(a,1:length(face)) = face;

      end

      % write back to class as vector3d
      cS.V = vector3d(V.');
      
      % scale vertices such that maximum distance between them is 1
      cS.V = cS.V(:) ./ max(norm(cS.V)) ./ 2;
      
      cS.F = F;
      
    end
    
    function cs = get.CS(cS)
      cs = cS.N.CS;
    end
  end

  methods (Static = true)
  
    function cS = quartz(cs)
      
      if nargin == 0, cs = loadCIF('quartz'); end

      m = Miller({1,0,-1,0},cs);  % hexagonal prism
      r = Miller({1,0,-1,1},cs);  % positive rhomboedron, usally bigger then z
      z = Miller({0,1,-1,1},cs);  % negative rhomboedron
      s1 = Miller({2,-1,-1,1},cs);% left tridiagonal bipyramid
      s2 = Miller({1,1,-2,1},cs); % right tridiagonal bipyramid
      x1 = Miller({6,-1,-5,1},cs);% left positive Trapezohedron
      x2 = Miller({5,1,-6,1},cs); % right positive Trapezohedron
      
      % select faces to plot
      N = [4*m,2*r,1.8*z,1.4*s1,0.6*x1];

      cS = crystalShape(N);
      
    end
    
    function cS = hex(cs)
      
      cS = crystalShape(Miller({1,0,0},{0,0,1},cs,'hkl'));
      
    end
    
    function demo
      
      % import some data
      CS = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)');

      fname = fullfile(mtexDataPath,'EBSD','titanium.txt');
      ebsd = loadEBSD(fname, 'interface','generic', 'CS', CS,...
        'ColumnNames', {'phi1' 'Phi' 'phi2' 'phase' 'ci' 'iq' 'sem_signal' ...
        'x' 'y' 'grainId'});

      % compute grains
      grains = calcGrains(ebsd('indexed'));
      grains = smooth(grains,4);

      % plot the grain boundary
      plot(grains.boundary,'micronbar','off','figSize','large')

      % use quartz crystals 
      cS = crystalShape.quartz;
      %cS = crystalShape.hex(ebsd.CS);
      
      % and plot them 
      hold on
      plot(grains,0.8 * cS,'FaceColor','light blue','DisplayName','Titanium')
      hold off

    end
    
  end
    
end