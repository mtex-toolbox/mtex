classdef S2FunTri < S2Fun
% a class representing a function on the sphere by values at grid points
%
% The function is given by its values at the vertices of a spherical
% triangulation and interpolated linearly in between. This is the
% representation used for measured data, e.g. a pole figure.
%
% Syntax
%   sF = S2FunTri(nodes,values)
%   sF = S2FunTri(nodes,values,s)
%   sF = S2FunTri(fun)
%
% Input
%  nodes  - @vector3d or @S2Triangulation
%  values - function value at each node
%  s      - @symmetry the nodes are symmetrised with
%  fun    - @S2Fun or @function_handle, sampled on an equispaced grid
%
% Output
%  sF - @S2FunTri
%
% Class Properties
%  tri       - @S2Triangulation
%  vertices  - @vector3d, the nodes of the triangulation
%  values    - function value at each node
%  antipodal - f(v) = f(-v)
%  isReal    - the function takes only real values
%
% Example
%
%   v = equispacedS2Grid('resolution',5*degree);
%   sF = S2FunTri(v,dot(v,vector3d.Z))
%
% See also
% S2Fun S2FunHarmonic S2Triangulation

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

      % the frame of the vertices, not a resolved convention - that
      % would pin a merely inherited default
      sF.framePrivate = sF.tri.vertices.frame;

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

      displayClass(sF,inputname(1),'moreInfo',...
        referenceFrame.headerChar(sF.frame,sF.how2plot),varargin{:});

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
  



