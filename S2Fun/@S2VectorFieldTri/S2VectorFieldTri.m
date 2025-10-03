classdef S2VectorFieldTri < S2VectorField
% a class representing a vector valued function on the sphere
  
  properties
    tri       % S2Triangulation
    values = vector3d  % function values
  end
  
  properties (Dependent = true)
    vertices
    antipodal
  end
  
  methods
    
    function sVF = S2VectorFieldTri(nodes,values)
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

    function display(sF,varargin)

      %displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact'),varargin{:});
      displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact'),varargin{:});

      if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

      disp(['  vertices: ' size2str(sF.vertices)]);
      if sF.antipodal, disp('  antipodal: true'); end
      disp(' ');

    end
    
  end

end
