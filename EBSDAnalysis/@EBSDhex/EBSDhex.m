classdef EBSDhex < EBSDgrid
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
    dx
    dy
  end
  
  methods
      
    function ebsd = EBSDhex(pos,rot,phaseId,phaseMap,CSList,dHex,isRowAlignment,varargin)
      % generate a hexagonal EBSD object
      %
      % Syntax 
      %   EBSDhex(rot,phases,CSList,dHex,isRowAlignment,)
      
      if nargin == 0, return; end            
      
      sGrid = size(rot);
      ebsd.pos = pos;
      ebsd.rotations = rotation(rot);
      ebsd.phaseId = phaseId(:);
      ebsd.phaseMap = phaseMap;
      ebsd.CSList = ensureCSArray(CSList);
      ebsd.id = reshape(1:prod(sGrid),sGrid);
            
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
      ebsd.opt = get_option(varargin,'opt',struct);
                  
      % set up unit cell
      ebsd.dHex = dHex;
      ebsd.isRowAlignment = isRowAlignment;
      
      omega = (0:60:300)*degree + 30*isRowAlignment*degree;
      ebsd.unitCell = dHex * vector3d(cos(omega.'), sin(omega.'),0);
      
      if isempty(pos)
        [cols,rows] = meshgrid(1:size(rot,2),1:size(rot,1));

        if ebsd.isRowAlignment
          x = (cols-1+0.5*iseven(rows)) * ebsd.dx;
          y = (rows-1) * ebsd.dy;
        else
          x = (cols-1) * ebsd.dx;
          y = (rows-1+0.5*iseven(cols)) * ebsd.dy;
        end
        ebsd.pos = vector3d(x,y,0);
      end
      
    end
           
    % --------------------------------------------------------------
    
    
    function of = get.offset(ebsd)
      if ebsd.isRowAlignment
        of = sign(ebsd.pos.x(2,1) - ebsd.pos.x(1,1));
      else
        of = sign(ebsd.pos.y(1,2) - ebsd.pos.y(1,1));
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
    
    
    function [row,col] = pos2ind(ebsd,x,y)
      % nearest neighbor search
      
      x = x - ebsd.pos.x(1);
      y = y - ebsd.pos.y(1);
      
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
      
      if nargout < 2
        ind = ~isnan(row);
        row(ind) = sub2ind(size(ebsd),row(ind),col(ind));
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
    % gO = log(ori1,ori2.symmetrise, SO3TangentSpace.leftVector) % true for this
    % gO = log(ori1.symmetrise,ori2, SO3TangentSpace.leftVector) % true for this
    
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
