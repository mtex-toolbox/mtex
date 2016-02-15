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
  end
  
  methods
      
    function ebsd = EBSDsquare(rot,phaseId,phaseMap,CSList,dxy,varargin)
      % generate a rectangular EBSD object
      %
      % Syntax 
      %   EBSD(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId;
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = CSList;
      ebsd.id = reshape(1:prod(sGrid),sGrid);
            
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
                  
      % get unit cell
      ebsd.dx = dxy(1);
      ebsd.dy = dxy(2);
      if check_option(varargin,'uniCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd.unitCell = 0.5 * [dxy(1) * [1;1;-1;-1],dxy(1) * [1;-1;-1;1]];
      end
    end
           
    % --------------------------------------------------------------
    
    function varargout = size(ebsd,varargin)
      [varargout{1:nargout}] = size(ebsd.id,varargin{:});
    end
           
    function gX = get.gradientX(ebsd)
      ori = ebsd.orientations;
          
      ori_ref = ori(:,[2:end end-1]);
      gX = log(ori,ori_ref) ./ ebsd.dx;
      gX(:,end) = - gX(:,end);
    end
    
    function gY = get.gradientY(ebsd)
      ori = ebsd.orientations;
          
      ori_ref = ori([2:end end-1],:);
      gY = log(ori,ori_ref) ./ ebsd.dy;
      gY(end,:) = - gY(end,:);
    end
    
  end
      
end
