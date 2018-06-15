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
      
      % extract orientations
      ori = ebsd.orientations;
      
      ori_right = ori(:,[2:end end-1]);
      gX = log(ori_right,ori,'left') ./ ebsd.dx;
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
      gY = log(ori_up,ori,'left') ./ ebsd.dy;
      gY(end,:) = - gY(end,:);
      
      % ignore grain boundaries if possible
      try
        gY(ebsd.grainId ~= ebsd.grainId([2:end end-1],:)) = NaN;
      end
      
    end
    
    % some testing code - gradient can be either in specimen coordinates or
    % in crystal coordinates 
    % 
    % cs = crystalSymmetry('321')
    % ori1 = orientation.rand(cs)
    % ori2 = orientation.rand(cs)
    %
    % the following output should be constant
    % gO = log(ori1,ori2.symmetrise,'left') % true for this
    % gO = log(ori1.symmetrise,ori2,'left') % true for this
    
    
  end
      
end
