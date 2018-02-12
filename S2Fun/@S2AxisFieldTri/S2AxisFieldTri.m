classdef S2AxisFieldTri < S2AxisField
% a class represeneting a function on the sphere
  
  properties
    tri       % S2Triangulation
    values = vector3d  % function values
  end
  
  properties (Dependent = true)
    vertices
    antipodal
  end
  
  methods
    
    function sVF = S2AxisFieldTri(nodes,values)
      % initialize a spherical vector field
      
      if nargin == 0, return; end

      if isa(nodes,'function_handle')
        n = equispacedS2Grid('resolution',1.5*degree);
        values = nodes(n);
        nodes = n;
      end
      
      if isa(nodes,'S2Triangulation')
        sVF.tri = nodes;
      else
        sVF.tri = S2Triangulation(nodes);
      end

      sVF.values = values;
      
    end
    
    function v = get.vertices(S2F)
      v = S2F.tri.vertices;
    end
    
    function v = get.antipodal(S2F)
      v = S2F.tri.antipodal;
    end
    
    function S2F = set.vertices(S2F,v)
      if ~isempty(S2F.values), S2F.values = S2F.eval(v); end
      S2F.tri.vertices = v;
      S2F.tri.update;
    end
    
  end

end
