classdef S2VectorFieldTri < S2VectorField
% a class representing a vector field on the sphere by values at nodes
%
% The field is given by a @vector3d at every vertex of a spherical
% triangulation and interpolated linearly in between.
%
% Syntax
%   vF = S2VectorFieldTri(nodes,values)
%   vF = S2VectorFieldTri(fun)
%
% Input
%  nodes  - @vector3d or @S2Triangulation
%  values - @vector3d, the field value at each node
%  fun    - @function_handle, sampled on an equispaced grid
%
% Output
%  vF - @S2VectorFieldTri
%
% Class Properties
%  tri       - @S2Triangulation
%  vertices  - @vector3d, the nodes of the triangulation
%  values    - @vector3d, the field value at each node
%  antipodal - vF(v) = vF(-v)
%
% Example
%
%   v = equispacedS2Grid('resolution',10*degree);
%   vF = S2VectorFieldTri(v,cross(v,vector3d.Z))
%
% See also
% S2VectorField S2VectorFieldHarmonic S2Triangulation

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
        [nodes,values] = uniqueData(nodes,values);
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
      displayClass(sF,inputname(1),varargin{:});
      
      if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

      disp(['  vertices: ' size2str(sF.vertices)]);
      if sF.antipodal, disp('  antipodal: true'); end
      disp(' ');

    end

  end
    
  methods(Static = true)
    sVF = example(varargin)
  end
    
end
