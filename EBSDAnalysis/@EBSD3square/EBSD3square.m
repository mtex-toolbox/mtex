classdef EBSD3square < EBSD3
  % EBSD data on a rectangular grid. In contrast to arbitrary EBSD data the
  % values are stored in a matrix.
  
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
    gradientX       % orientation gradient in x
    gradientY       % orientation gradient in y
    gradientZ       % orientation gradient in z    
  end
  
  methods
      
    function ebsd = EBSD3square(pos,rot,phases,CSList,dxyz,varargin)
      % generate a EBSD object
      %
      % Syntax 
      %   EBSD3square(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      
      ebsd.pos = pos;
      ebsd.rotations = rotation(rot);
      ebsd = ebsd.init(phases,CSList);
      ebsd.id = (1:numel(phases)).';
      
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
        [x,y,z] = meshgrid(1:size(rot,2),1:size(rot,1),1:size(rot,3));
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
           
    function gX = get.gradientX(ebsd)
      % gives the gradient in X direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
      
      ori_right = ori(:,[2:end end-1],:);
      gX = log(ori_right,ori, SO3TangentSpace.leftVector) ./ ebsd.dx;
      gX(:,end) = - gX(:,end);
      
      % ignore grain boundaries if possible
      if isfield(ebsd.prop.grainId)
        gX(ebsd.prop.grainId ~= ebsd.prop.grainId(:,[2:end end-1],:)) = NaN;
      end
      
    end
    
    function gY = get.gradientY(ebsd)
      % gives the gradient in Y direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
          
      ori_up = ori([2:end end-1],:,:);
      gY = log(ori_up,ori, SO3TangentSpace.leftVector) ./ ebsd.dy;
      gY(end,:) = - gY(end,:);
      
      % ignore grain boundaries if possible
      if isfield(ebsd.prop.grainId)
        gY(ebsd.prop.grainId ~= ebsd.prop.grainId([2:end end-1],:,:)) = NaN;
      end
      
    end
   

    function gZ = get.gradientZ(ebsd)
      % gives the gradient in Z direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
          
      ori_out = ori(:,:,[2:end end-1]);
      gZ = log(ori_out,ori, SO3TangentSpace.leftVector) ./ ebsd.dz;
      gZ(end,:) = - gZ(end,:);
      
      % ignore grain boundaries if possible
      if isfield(ebsd.prop.grainId)
        gZ(ebsd.prop.grainId ~= ebsd.prop.grainId(:,:,[2:end end-1])) = NaN;
      end
      
    end

    function e = end(ebsd3,i,n)
      if n==1
        e = size(ebsd3.id,1);
      else
        e = size(ebsd3.id,i);
      end
    end
       
  end
      
end
