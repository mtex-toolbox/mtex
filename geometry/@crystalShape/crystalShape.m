classdef crystalShape 
% a class representing crystal shapes based on a paper by Joerg Enderlein,
% Uni Regensburg, joerg.enderlein@chemie.uni-regensburg.de
% 
  
  properties
    N % face normals
    V % vertices
    F % faces
    habitus = 1
    extension = [1 1 1];
  end
  
  properties (Dependent = true)
    CS % crystal symmetry
  end
  
  methods
    
    function cS = crystalShape(N,habitus,extension)
      
      if isa(N,'crystalSymmetry')
        N = basicHKL(cs);
        N = N .* N.dspacing;
      else
        %N = unique(N.symmetrise,'noSymmetry');
      end
      cS.N = N;
      
      if nargin >= 2, cS.habitus = habitus; end
      if nargin >= 3, cS.extension = extension; end
      
      cS = cS.update;
    end
        
    function cS = update(cS)

      % ensure N is vector3d and apply habitus scaling
      N = cS.N(:); %#ok<*PROP>
      if cS.habitus >0
        N = N ./ ((abs(N.h) * cS.extension(1)).^cS.habitus + ...
          (abs(N.k) * cS.extension(2)).^cS.habitus + ...
          (abs(N.l) * cS.extension(3)).^cS.habitus).^(1/cS.habitus);
      end
      
      N = unique(vector3d(N.symmetrise));
            
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
      cS.F = nan(length(N),length(N));
      
      % for all potential faces
      for a = 1:length(N)
        
        % which vertices belong to face a ?
        B = find(V * N(a,:).' > 1-tol).';
        
        % which featureEdges belong to face a ?
        A = FE(:,all(ismember(FE,B)));
        
        % conect edges to form a polygon
        face = cell2mat(EulerCycles(A.'));
        cS.F(a,1:length(face)) = face;

      end

      % write back to class as vector3d
      cS.V = vector3d(V.');
      
      % scale vertices such that maximum distance between them is 1
      cS.V = cS.V(:) ./ max(norm(cS.V)) ./ 2;
      
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
      
      % select faces and scale them nicely
      %N = [4*m,2*r,1.8*z,1.4*s1,0.6*x1];
      %cS = crystalShape(N,1.2,[1,1.2,1.2]);
      
      % if we use habitus scaling is implicite
      N = [m,r,z,s2,x2];
      cS = crystalShape(N,1.2,[1,1.2,1]);
   
    end
    
    function cS = hex(cs)
      
      cS = crystalShape(Miller({1,0,0},{0,0,1},cs,'hkl'));
      
    end
    
    function cS = topaz      
      cs = crystalSymmetry('mmm',[0.52854,1,0.47698]);
      
      N = Miller({0,0,1},{2,2,3},{2,0,1},{0,2,1},{1,1,0},{1,2,0},{2,2,1},...
        {0,4,1},cs);
      
      cS = crystalShape(N,1.2,[0.3,0.3,1]);
    end

    function cS = apatite      
      cs = crystalSymmetry('6/m',[1,1,0.7346],'mineral','apatite');
      
      N = Miller({1,0,0},{0,0,1},{1,0,1},{1,0,2},...
        {2,0,1},{1,1,2},{1,1,1},{2,1,1},{3,1,1},{2,1,0},cs);
      
      cS = crystalShape(N,1.2,[0.6,0.6,1]);      
    end      

    function cS = garnet
      cs = crystalSymmetry('m3m','mineral','garnet');
      
      N = Miller({1,1,0},{2,1,1},cs);
      
      cS = crystalShape(N,1.5);      
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
      cS = crystalShape.apatite;
      %cS = crystalShape.hex(ebsd.CS);
      
      % and plot them 
      hold on
      plot(grains,0.6 * cS,'FaceColor','light blue','DisplayName','Titanium')
      hold off

    end
    
  end
    
end