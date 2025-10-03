classdef S2FunTri < S2Fun
% a class representing a function on the sphere
  
  properties
    tri          % S2Triangulation
    values = []  % function values
    s = specimenSymmetry
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
        if nargin==2, s = specimenSymmetry; end
        nodes = symmetrise(nodes(:)',s);
        values = repmat(values(:)',size(nodes,1),1);
        nodes.antipodal = false;
        sF.tri = S2Triangulation(nodes);
      end
      
      sF.values = values;

      sF.s.how2plot = nodes.how2plot;

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

      displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact'),varargin{:});

      if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

      disp(['  vertices: ' size2str(sF.vertices)]);
      if sF.antipodal, disp('  antipodal: true'); end
      disp(' ');

    end


  end    

  
  methods (Static = true)
    
    function sF = demo
      
      %mtexdata dubna;
      
      %sF = S2Fun(pf({1}).r,pf({1}).intensities);
      
      %plot(sF,'upper');
       
      odf = SantaFe;
      
      v = equispacedS2Grid('points',1000);
      
      values = odf.calcPDF(Miller(1,0,0,odf.CS),v);
      
      sF = S2FunTri(v,values);
      
      plot(sF,'upper')
      
    end
  end
end
  



