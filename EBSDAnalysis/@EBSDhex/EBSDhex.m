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
  end
  
  properties (Dependent = true)    
    offset          % +/- 1  dependent on whether the second line is shifted in or our
    gradientX       % orientation gradient in x
    gradientY       % orientation gradient in y
    dx
    dy
  end
  
  methods
      
    function ebsd = EBSDhex(rot,phaseId,phaseMap,CSList,dHex,isRowAlignment,varargin)
      % generate a hexagonal EBSD object
      %
      % Syntax 
      %   EBSDhex(rot,phases,CSList,dHex,isRowAlignment,)
      
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
    
    
    function of = get.offset(ebsd)
      if ebsd.isRowAlignment
        of = sign(ebsd.prop.x(2,1) - ebsd.prop.x(1,1));
      else
        of = sign(ebsd.prop.y(1,2) - ebsd.prop.y(1,1));
      end
    end
    
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
      
        [r,c] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
        
        % one right
        c = c + 1;
        
        % go in oposite direction at the right boundary
        c(c>size(ebsd,2)) = c(c>size(ebsd,2))-2;
        
        % one up
        r = r - xor(ebsd.offset == 1, ~iseven(c));
                
        % compute gradient 1
        ind1 = sub2ind(size(ebsd), max(r,1), c);
        gX1 = log(ori(ind1),ori,'left');
        
        if isfield(ebsd.prop,'grainId')
          gX1(ebsd.grainId ~= ebsd.grainId(ind1)) = NaN;
        end
        
        % compute gradient 2
        ind2 = sub2ind(size(ebsd), min(r+1,size(ebsd,1)), c);
        gX2 = log(ori(ind2),ori,'left');
        
        if isfield(ebsd.prop,'grainId')
          gX2(ebsd.grainId ~= ebsd.grainId(ind2)) = NaN;
        end
                
        gX = mean(cat(3,gX1,gX2),3,'omitnan') ./ ebsd.dx;
        
        gX(end,:) = - gX(end,:);
        
        
      end
      
    end
    
    function gY = get.gradientY(ebsd)
      % gives the gradient in Y direction with respect to specimen
      % coordinate system
      
      % extract orientations
      ori = ebsd.orientations;
      
      if ebsd.isRowAlignment

        [r,c] = ndgrid(1:size(ebsd,1),1:size(ebsd,2));
        
        % one up
        r = r+1;
        
        % go in oposite direction at the upper boundary
        r(r>size(ebsd,1)) = r(r>size(ebsd,1))-2;
        
        % one left
        c = c - xor(ebsd.offset == 1, ~iseven(r));
                
        % compute gradient 1
        ind1 = sub2ind(size(ebsd), r, max(1,c));
        gY1 = log(ori(ind1),ori,'left');
        
        if isfield(ebsd.prop,'grainId')
          gY1(ebsd.grainId ~= ebsd.grainId(ind1)) = NaN;
        end
        
        % compute gradient 2
        ind2 = sub2ind(size(ebsd), r, min(size(ebsd,2),c+1));
        gY2 = log(ori(ind2),ori,'left');
        
        if isfield(ebsd.prop,'grainId')
          gY2(ebsd.grainId ~= ebsd.grainId(ind2)) = NaN;
        end
                
        gY = mean(cat(3,gY1,gY2),3,'omitnan') ./ ebsd.dy;
        
        gY(end,:) = - gY(end,:);
                    
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
    
    function [x,y,z] = hex2cube(ebsd,row,col)
      % convert offset coordinates into cube coordinates

      % convert to row, col indices
      if nargin == 2, [row,col] = ind2sub(size(ebsd),row); end
      
      %col = col - 1 + ebsd.offset * ~iseven(round(row));
      col = col - 1;
      row = row - 1 ;
            
      if ebsd.isRowAlignment
        x = col - (row - ebsd.offset * ~iseven(round(row))) / 2;
        z = row;
      else
        x = row - (col - ebsd.offset * ~iseven(round(col))) / 2;
        z = col;
      end
      y = -x-z;
      
    end
    
    function [row,col] = cube2hex(ebsd,x,y,z)
      % convert cube coordinates into offset coordinates
      
      if ebsd.isRowAlignment
        col = 1 + x + (z - ebsd.offset * ~iseven(round(z))) / 2;
        row = 1 + z;
      else
        col = 1 + x;
        row = 1 + z + (x - ebsd.offset * ~iseven(round(x))) / 2;
      end
      
      % ensure inside the box
      isInside = row > 0 & col > 0 & row <= size(ebsd,1) & col <= size(ebsd,2);
      row(~isInside) = NaN;
      col(~isInside) = NaN;
      
      if nargout < 2, row = sub2ind(size(ebsd),row,col); end
      
    end

    function ind = neighbors(ebsd,ind,k,radius)

      if nargin == 3, radius = 1; end
      
      dnx = [0  1  1  0 -1 -1  0  1]; cnx = cumsum(dnx);
      dny = [0 -1  0  1  1  0 -1 -1]; cny = cumsum(dny);
      dnz = [0  0 -1 -1  0  1  1  0]; cnz = cumsum(dnz);
      
      i = 1 + floor(k / radius); j = k - radius * (i-1);
      
      [x,y,z] = hex2cube(ebsd,ind);
      
      x = x - radius + radius * cnx(i) + j*dnx(i+1);
      y = y          + radius * cny(i) + j*dny(i+1);
      z = z + radius + radius * cnz(i) + j*dnz(i+1);
      
      ind = cube2hex(ebsd,x,y,z);
      
    end
    
    
    function [row,col] = xy2ind(ebsd,x,y)
      % nearest neighbour search
      
      x = x-ebsd.prop.x(1);
      y = y-ebsd.prop.y(1);
      
      
      % convert to axial coordinates
      if ebsd.isRowAlignment        
        q = (sqrt(3)/3 * x - 1./3 * y) / ebsd.dHex;
        r = (                2./3 * y) / ebsd.dHex;
      else        
        q = ( 2./3 * x                ) / ebsd.dHex;
        r = (-1./3 * x + sqrt(3)/3 * y) / ebsd.dHex;        
      end
      
      % convert to cube coordinates
      cx = q; cz = r; cy = -cx - cz;
      
      % round in cube coordinates
      rx = round(cx); ry = round(cy); rz = round(cz);
      dx = abs(cx-rx); dy = abs(cy-ry); dz = abs(cz-rz);
      
      ind1 = dx>dy & dx>dz;
      ind2 = dy > dz;
      rx(ind1) = -ry(ind1) - rz(ind1); %#ok<*PROPLC>
      ry(~ind1 & ind2) = -rx(~ind1 & ind2) - rz(~ind1 & ind2);
      rz(~ind1 & ~ind2) = -rx(~ind1 & ~ind2) - ry(~ind1 & ~ind2);
      
      % convert to offset coordinates
      [row,col] = ebsd.cube2hex(rx,ry,rz);
      
      if nargout < 2, row = sub2ind(size(ebsd),row,col); end
      
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
  
  methods (Static = true)
    
    function checkCube2Hex
      
      [r,c] = ndgrid(1:10,1:10);
      
      ebsd = EBSDhex;
      
      [x,y,z] = ebsd.hex2cube(r,c);
      [r2,c2] = ebsd.cube2hex(x,y,z);
      
      max((r-r2).^2 + (c-c2).^2)
      
    end
    
  end
  
      
end
