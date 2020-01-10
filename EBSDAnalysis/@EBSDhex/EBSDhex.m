classdef EBSDhex < EBSD
  % EBSD data on a hexagonal grid. In contrast to arbitrary EBSD data the
  % values are stored in a matrix.
  
  % properties with as many rows as data
  properties
  end
  
  % general properties
  properties
    dHex
    isRowAlignment
    offset %
  end
  
  properties (Dependent = true)    
    gradientX       % orientation gradient in x
    gradientY       % orientation gradient in y
    dx
    dy
  end
  
  methods
      
    function ebsd = EBSDhex(rot,phaseId,phaseMap,CSList,dHex,isRowAlignment,offset,varargin)
      % generate a hexagonal EBSD object
      %
      % Syntax 
      %   EBSDhex(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId(:);
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = CSList;
      ebsd.id = reshape(1:prod(sGrid),sGrid);
            
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
                  
      % set up unit cell
      ebsd.dHex = dHex;
      ebsd.offset = offset;
      ebsd.isRowAlignment = isRowAlignment;
      
      omega = (0:60:300)*degree + 30*isRowAlignment*degree;
      ebsd.unitCell = dHex * [cos(omega.') sin(omega.')];
      
      if ~isfield(ebsd.prop,'x')
        [cols,rows] = meshgrid(1:size(rot,2),1:size(rot,1));

        if ebsd.isRowAlignment
          ebsd.prop.x = (cols-1+0.5*iseven(rows)) * ebsd.dx;
          ebsd.prop.y = (rows-1) * ebsd.dy;
        else
          ebsd.prop.x = (cols-1) * ebsd.dx;
          ebsd.prop.y = (rows-1+0.5*iseven(cols)) * ebsd.dy;
        end
      end
      
    end
           
    % --------------------------------------------------------------
    
    
    function dx = get.dx(ebsd)
      if ebsd.isRowAlignment
        dx = ebsd.dHex * sqrt(3);
      else
        dx = 1.5 * ebsd.dHex;
      end
    end
    
    function dy = get.dy(ebsd)
      if ebsd.isRowAlignment
        dy = 1.5 * ebsd.dHex;
      else
        dy = ebsd.dHex * sqrt(3);
      end
    end
    
    
    function gX = get.gradientX(ebsd)
      % gives the gradient in X direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
      
      if ebsd.isRowAlignment
        ori_right = ori(:,[2:end end-1]);
        gX = log(ori_right,ori,'left') ./ ebsd.dHex;
        gX(:,end) = - gX(:,end);
      
        % ignore grain boundaries if possible
        try
          gX(ebsd.grainId ~= ebsd.grainId(:,[2:end end-1])) = NaN;
        end
      else
        
      end
      
    end
    
    function gY = get.gradientY(ebsd)
      % gives the gradient in Y direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
          
      if ebsd.isRowAlignment
        ori_up = ori([2:end end-1],:);
        
        if ebsd.offset == 1
          ori_up(1:2:end)
        end
        
        
        gY = log(ori_up,ori,'left') ./ ebsd.dHex;
        gY(end,:) = - gY(end,:);
        
        %ori_up2 = ori([2:2:end end-1],:);
      
        try
          gY(ebsd.grainId ~= ebsd.grainId([2:end end-1],:)) = NaN;
        end
              
      else
        ori_up = ori([2:end end-1],:);
        gY = log(ori_up,ori,'left') ./ ebsd.dy;
        gY(end,:) = - gY(end,:);
        
        % ignore grain boundaries if possible
        try
          gY(ebsd.grainId ~= ebsd.grainId([2:end end-1],:)) = NaN;
        end
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
