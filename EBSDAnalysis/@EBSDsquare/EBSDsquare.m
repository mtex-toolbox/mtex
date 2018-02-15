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
      ebsd.phaseId = phaseId(:);
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
        ebsd.unitCell = 0.5 * [dxy(1) * [1;1;-1;-1],dxy(2) * [1;-1;-1;1]];
      end
    end
           
    % --------------------------------------------------------------
    
    function gX = get.gradientX(ebsd)
      % gives the gradient in X direction with respect to specimen
      % coordinate system
      
      ori = ebsd.orientations;
          
      ori_right = ori(:,[2:end end-1]);
      gX = ori .* log(ori_right,ori) ./ ebsd.dx;
      gX(:,end) = - gX(:,end);
    end
    
    function gY = get.gradientY(ebsd)
      % gives the gradient in Y direction with respect to specimen
      % coordinate system
      
      ori = ebsd.orientations;
          
      ori_up = ori([2:end end-1],:);
      gY = ori .* log(ori_up,ori) ./ ebsd.dy;
      gY(end,:) = - gY(end,:);
    end
    
    % some testing code - gradient can be either in specimen coordinates or
    % in crystal coordinates 
    % 
    % cs = crystalSymmetry('321')
    % ori1 = orientation.rand(cs)
    % ori2 = orientation.rand(cs)
    %
    % the following output should be constant
    % gO = log(ori1,ori2.symmetrise) % but not true for this
    % gO = log(ori1.symmetrise,ori2) % true for this
    %
    % gO = ori2.symmetrise .* log(ori1,ori2.symmetrise) % true for this
    % gO = ori2 .* log(ori1.symmetrise,ori2) % true for this
    
  end
      
end
