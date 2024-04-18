classdef EBSDsquare < EBSD
  % EBSD data on a rectangular grid. In contrast to arbitrary EBSD data the
  % values are stored in a matrix.
  
  % properties with as many rows as data
  properties
  end
  
  % general properties
  properties
    dx
    dy    
  end
  
  properties (Dependent = true)    
    gradientX       % orientation gradient in x
    gradientY       % orientation gradient in y
    xmin
    xmax
    ymin
    ymax
  end
  
  methods
      
    function ebsd = EBSDsquare(pos,rot,phaseId,phaseMap,CSList,dxyz,varargin)
      % generate a rectangular EBSD object
      %
      % Syntax 
      %   EBSD(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      
      ebsd.pos = pos;
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId(:);
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = CSList;
      ebsd.id = 1:prod(sGrid);
      
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
      ebsd.opt = get_option(varargin,'opt',struct);
      
      % correctly reshape all properties
      ebsd = reshape(ebsd,sGrid);
                  
      % get unit cell
      ebsd.dx = dxyz(1);
      ebsd.dy = dxyz(2);
      if check_option(varargin,'unitCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd.unitCell = 0.5 * vector3d(dxyz(1) * [1;1;-1;-1],dxyz(2) * [1;-1;-1;1],0);
      end
      
      if isempty(pos)        
        [x,y] = meshgrid(1:size(rot,2),1:size(rot,1));
        ebsd.pos = vector3d((x-1) * dxyz(1),(y-1) * dxyz(2),0);
      end
           
    end

    function [x,y] = ind2sub(ebsd,ind)
      [x,y] = ind2sub(size(ebsd),ind);
    end

    function [ebsd,newId] = gridify(ebsd,varargin)
      % nothing to do :)
      newId = (1:length(ebsd)).';
    end
           
    % --------------------------------------------------------------
    
    function out = get.xmin(ebsd)
      out = ebsd.pos.x(1);
    end
    
    function out = get.xmax(ebsd)
      out = ebsd.pos.x(end);
    end
    
    function out = get.ymin(ebsd)
      out = ebsd.pos.y(1);
    end
    
    function out = get.ymax(ebsd)
      out = ebsd.pos.y(end);
    end
    
    
    function gX = get.gradientX(ebsd)
      % gives the gradient in X direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
      
      ori_right = ori(:,[2:end end-1]);
      gX = log(ori_right,ori, SO3TangentSpace.leftVector) ./ ebsd.dx;
      gX(:,end) = - gX(:,end);
      
      % ignore grain boundaries if possible
      try
        gX(ebsd.grainId ~= ebsd.grainId(:,[2:end end-1])) = NaN;
      end
      
    end
    
    function gY = get.gradientY(ebsd)
      % gives the gradient in Y direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
          
      ori_up = ori([2:end end-1],:);
      gY = log(ori_up,ori, SO3TangentSpace.leftVector) ./ ebsd.dy;
      gY(end,:) = - gY(end,:);
      
      % ignore grain boundaries if possible
      try
        gY(ebsd.grainId ~= ebsd.grainId([2:end end-1],:)) = NaN;
      end
      
    end
   
    function h = gridBoundary(ebsd)

      x = ebsd.xmin:ebsd.dx:ebsd.xmax;
      y = ebsd.ymin-ebsd.dy:ebsd.dy:ebsd.ymax+ebsd.dy;

      h= [
        repmat(ebsd.xmin-ebsd.dx, numel(y),1), y.' ; ...
        x.', repmat(ebsd.ymin-ebsd.dy, numel(x), 1) ; ...
        x.', repmat(ebsd.ymax+ebsd.dy, numel(x), 1) ; ...
        repmat(ebsd.xmax+ebsd.dx, numel(y),1), y.'];
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
