classdef EBSDsquare < EBSD
  % EBSD data on a rectangular grid. In contrast to arbitrary EBSD data the
  % values are stored in a matrix.
  
  properties (Dependent = true)
    gradient1 % orientation gradient in dimension 1
    gradient2 % orientation gradient in dimension 2
    gradientX % orientation gradient in x
    gradientY % orientation gradient in y
    gradientZ % orientation gradient in z
    d1, d2    % @vector3d, directions of the two grid dimensions 
  end
  
  methods
      
    function ebsd = EBSDsquare(pos,rot,phaseId,phaseMap,CSList,varargin)
      % generate a rectangular EBSD object
      %
      % Syntax 
      %   EBSD(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      if isa(pos,"EBSD") 
        ebsd.id = pos.id;
        ebsd.pos = pos.pos; 
        ebsd.phaseId = pos.phaseId;
        ebsd.CSList = pos.CSList;
        ebsd.phaseMap = pos.phaseMap;
        ebsd.rotations = pos.rotations;
        
        return
      end

      sGrid = size(rot);
      
      ebsd.pos = pos;
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId(:);
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = CSList;
      ebsd.id = 1:prod(sGrid);
      
      % extract additional properties
      ebsd.prop = get_option(varargin,'prop',struct);
      ebsd.opt = get_option(varargin,'opt',struct);
      
      % correctly reshape all properties
      ebsd = reshape(ebsd,sGrid);
      
      if isempty(pos)        
        [x,y] = meshgrid(1:size(rot,2),1:size(rot,1));
        dxyz = get_option(varargin,'dxy',[1 1]);
        ebsd.pos = vector3d((x-1) * dxyz(1),(y-1) * dxyz(2),0);
      end
      
      % get unit cell
      if check_option(varargin,'unitCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd.unitCell = 0.5 * (ebsd.d1 * [1;1;-1;-1] + ebsd.d2 * [1;-1;-1;1]);
      end
           
    end

    function [x,y] = ind2sub(ebsd,ind)
      [x,y] = ind2sub(size(ebsd),ind);
    end

    function [ebsd,newId] = gridify(ebsd,varargin)
      % nothing to do :)
      newId = (1:length(ebsd)).';
    end
           
    function e = end(ebsd,i,n)
      if n==1
        e = size(ebsd.id,1);
      else
        e = size(ebsd.id,i);
      end
    end

    % --------------------------------------------------------------
    
    function out = get.d1(ebsd)
      out = ebsd.pos(2,1) - ebsd.pos(1,1);
    end
    function out = get.d2(ebsd)
      out = ebsd.pos(1,2) - ebsd.pos(1,1);
    end
    
    function g1 = get.gradient1(ebsd)
      % gradient in first dimension in specimen coordinates
      
      % extract orientations
      ori = ebsd.orientations;
          
      ori_up = ori([2:end end-1],:);
      g1 = log(ori_up,ori, SO3TangentSpace.leftVector) ./ norm(ebsd.d1);
      g1(end,:) = - g1(end,:);
      
      % ignore grain boundaries if possible
      if isfield(ebsd.prop,'grainId')
        g1(ebsd.prop.grainId ~= ebsd.prop.grainId([2:end end-1],:)) = NaN;
      end      
    end

    function g2 = get.gradient2(ebsd)
      % gradient in second dimension in specimen coordinates
            
      % extract orientations
      ori = ebsd.orientations;
      
      ori_right = ori(:,[2:end end-1]);
      g2 = log(ori_right,ori, SO3TangentSpace.leftVector) ./ norm(ebsd.d2);
      g2(:,end) = - g2(:,end);
      
      % ignore grain boundaries if possible
      if isfield(ebsd.prop,'grainId')
        g2(ebsd.prop.grainId ~= ebsd.prop.grainId(:,[2:end end-1])) = NaN;
      end
      
    end

    function gX = get.gradientX(ebsd)
      % gradient in X direction in specimen coordinates
      if abs(dot(normalize(ebsd.d1),xvector)) > 1-1e-6
        gX = ebsd.gradient1 * sign(dot(ebsd.d1,xvector));
      elseif abs(dot(normalize(ebsd.d2),xvector)) > 1-1e-6
        gX = ebsd.gradient2 * sign(dot(ebsd.d2,xvector));
      elseif abs(dot(ebsd.N,xvector)) < 1e-6
        error('Todo')
      else
        gX = vector3d.nan(size(ebsd));
      end      
    end

    function gY = get.gradientY(ebsd)
      % gradient in Y direction in specimen coordinates

      if abs(dot(normalize(ebsd.d1),yvector)) > 1-1e-6
        gY = ebsd.gradient1 * sign(dot(ebsd.d1,yvector));
      elseif abs(dot(normalize(ebsd.d2),yvector)) > 1-1e-6
        gY = ebsd.gradient2 * sign(dot(ebsd.d2,yvector));
      elseif abs(dot(ebsd.N,yvector)) < 1e-6
        error('Todo')
      else
        gY = vector3d.nan(size(ebsd));
      end
    end

    function gY = get.gradientZ(ebsd)
      % gradient in Z direction in specimen coordinates

      if abs(dot(normalize(ebsd.d1),zvector)) > 1-1e-6
        gY = ebsd.gradient1 * sign(dot(ebsd.d1,zvector));
      elseif abs(dot(normalize(ebsd.d2),zvector)) > 1-1e-6
        gY = ebsd.gradient2 * sign(dot(ebsd.d2,zvector));
      elseif abs(dot(ebsd.N,zvector)) < 1e-6
        error('Todo')
      else
        gY = vector3d.nan(size(ebsd));
      end
    end
   
    function h = gridBoundary(ebsd)
      % this is used by the alpha shape algorithm
      % which assumes that we are in the xy plane

      ext = ebsd.extent;
      delta = ebsd.dPos;
      x = ext(1):delta:ext(2);
      y = ext(3)-delta:delta:ext(4)+delta;

      h= [
        repmat(ext(1)-delta, numel(y),1), y.' ; ...
        x.', repmat(ext(3)-delta, numel(x), 1) ; ...
        x.', repmat(ext(4)+delta, numel(x), 1) ; ...
        repmat(ext(2)+delta, numel(y),1), y.'];
    end

    % some testing code - gradient can be either in specimen coordinates or
    % in crystal coordinates 
    % 
    % cs = crystalSymmetry('321')
    % ori1 = orientation.rand(cs)
    % ori2 = orientation.rand(cs)
    %
    % the following output should be constant
    % gO = log(ori1,ori2.symmetrise,SO3TangentSpace.leftVector) % true for this
    % gO = log(ori1.symmetrise,ori2,SO3TangentSpace.leftVector) % true for this
       
  end
      
end
