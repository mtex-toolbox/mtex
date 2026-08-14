classdef S2FunTri < S2Fun
% a class representing a function on the sphere
  
  properties
    tri          % S2Triangulation
    values = []  % function values
    antipodal = false
    isReal = true
  end
  
  properties (Dependent = true)
    vertices
  end
  
  methods
    
    function sF = S2FunTri(nodes,values,s)      
      % initialize a spherical function
      if isa(nodes,'S2Fun')
        nodes = @(n) nodes.eval(n);
      end

      if isa(nodes,'function_handle')
        n = equispacedS2Grid('resolution',1.5*degree);
        values = nodes(n);
        nodes = n;
      end

      if isa(nodes,'S2Triangulation')
        sF.tri = nodes;
      else
        if nargin==2, s = specimenSymmetry.default; end
        nodes = symmetrise(nodes(:)',s);
        values = repmat(values(:)',size(nodes,1),1);
        nodes.antipodal = false;
        [nodes,values] = uniqueData(nodes,values);
        sF.tri = S2Triangulation(nodes);
      end
      
      sF.values = reshape(values,numel(sF.vertices),[]);

      % the frame and the private convention of the vertices, not the
      % resolved ones - that would pin a merely inherited default
      v = sF.tri.vertices;
      sF.framePrivate = v.frame;
      sF.how2plotPrivate = v.how2plotPrivate;

    end
    
    function v = get.vertices(S2F)
      v = S2F.tri.vertices;
    end
    
    function S2F = set.vertices(S2F,v)
      if ~isempty(S2F.values), S2F.values = S2F.eval(v); end
      S2F.tri.vertices = v;
      S2F.tri.update;
    end

    function display(sF,varargin)

      displayClass(sF,inputname(1),'moreInfo',char(sF.how2plot,'compact'),varargin{:});

      if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

      disp(['  vertices: ' size2str(sF.vertices)]);
      if sF.antipodal, disp('  antipodal: true'); end
      disp(' ');

    end


  end    

  
  methods (Static = true)
    sF = example(varargin);
  end
end
  



