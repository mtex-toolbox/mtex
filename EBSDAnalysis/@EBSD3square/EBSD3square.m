classdef EBSD3square < EBSD3
  % 3d EBSD data on a rectangular grid. In contrast to arbitrary EBSD3
  % data the values are stored in a three dimensional array, so that
  % ebsd(i,j,k) addresses a voxel and orientation gradients are available
  % along all three axes.
  %
  % Syntax
  %   ebsd = EBSD3square(pos,rot,phaseId,phaseMap,CSList,[dx dy dz])
  %
  % Input
  %  pos        - @vector3d, one per voxel
  %  rot        - @rotation, in array layout
  %  phaseId    - phase of each voxel as index into CSList
  %  phaseMap   - convert between phase = phaseMap(phaseId)
  %  CSList     - list of @crystalSymmetry
  %  dx, dy, dz - voxel size
  %
  % Output
  %  ebsd - @EBSD3square
  %
  % Class Properties
  %  dx, dy, dz - voxel size
  %  d1, d2, d3 - @vector3d, directions of the three array dimensions
  %  gradientX  - orientation gradient in x
  %  gradientY  - orientation gradient in y
  %  gradientZ  - orientation gradient in z
  %
  % See also
  % EBSD3 EBSD EBSDsquare
  %

  % properties with as many rows as data
  properties
  end
  
  % general properties
  properties
    dx
    dy
    dz
  end
  
  properties (Dependent = true)    
    d1
    d2
    d3    
    gradientX       % orientation gradient in x
    gradientY       % orientation gradient in y
    gradientZ       % orientation gradient in z    
  end
  
  methods
      
    function ebsd = EBSD3square(pos,rot,phaseId,phaseMap,CSList,dxyz,varargin)
      % generate a EBSD object
      %
      % Syntax 
      %   EBSD3square(pos,rot,phaseId,phaseMap,CSList,[dx dy dz])
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      
      ebsd.pos = pos;
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId(:);
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = ensureCSArray(CSList);
      ebsd.id = (1:prod(sGrid)).';
      
      % extract additional properties
      ebsd.prop = get_option(varargin,'prop',struct);
      ebsd.opt = get_option(varargin,'opt',struct);
      
      % correctly reshape all properties
      ebsd = reshape(ebsd,sGrid);
                  
      % get unit cell
      ebsd.dx = dxyz(1); ebsd.dy = dxyz(2); ebsd.dz = dxyz(3);

      if check_option(varargin,'unitCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd.unitCell = 0.5 * vector3d(dxyz(1) * [1;1;-1;-1;1;1;-1;-1],...
                                       dxyz(2) * [1;-1;-1;1;1;-1;-1;1],...
                                       dxyz(3) * [1;1;1;1;-1;-1;-1;-1]);
      end
      
      if isempty(pos)        
        [x,y,z] = ndgrid(1:size(rot,1),1:size(rot,2),1:size(rot,3));
        ebsd.pos = vector3d((x-1) * dxyz(1),(y-1) * dxyz(2),(z-1) * dxyz(3));
      end
           
    end

    function [x,y,z] = ind2sub(ebsd,ind)
      [x,y,z] = ind2sub(size(ebsd),ind);
    end

    function [ebsd,newId] = gridify(ebsd,varargin)
      % nothing to do :)
      newId = (1:length(ebsd)).';
    end

    function out = get.d1(ebsd)
      out = ebsd.pos(2,1,1) - ebsd.pos(1,1,1);
    end
    function out = get.d2(ebsd)
      out = ebsd.pos(1,2,1) - ebsd.pos(1,1,1);
    end
    function out = get.d3(ebsd)
      out = ebsd.pos(1,1,2) - ebsd.pos(1,1,1);
    end
           
    function g = gradientDim(ebsd,dim)
      % forward difference of the orientations along array dimension dim,
      % backward in the last layer

      ori = ebsd.orientations;

      fwd = repmat({':'},1,3);
      fwd{dim} = [2:size(ori,dim), size(ori,dim)-1];

      d = [norm(ebsd.d1) norm(ebsd.d2) norm(ebsd.d3)];
      g = log(ori(fwd{:}),ori,SO3TangentSpace.leftVector) ./ d(dim);

      last = repmat({':'},1,3);
      last{dim} = size(ori,dim);
      g(last{:}) = - g(last{:});

      % ignore grain boundaries if possible
      if isfield(ebsd.prop,'grainId')
        g(ebsd.prop.grainId ~= ebsd.prop.grainId(fwd{:})) = NaN;
      end

    end

    % the array dimensions carry x, y and z - see the constructor
    function gX = get.gradientX(ebsd), gX = gradientDim(ebsd,1); end
    function gY = get.gradientY(ebsd), gY = gradientDim(ebsd,2); end
    function gZ = get.gradientZ(ebsd), gZ = gradientDim(ebsd,3); end

    function e = end(ebsd3,i,n)
      if n==1
        e = size(ebsd3.id,1);
      else
        e = size(ebsd3.id,i);
      end
    end
       
  end
      
end
