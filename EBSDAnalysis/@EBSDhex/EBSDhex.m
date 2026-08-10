classdef EBSDhex < EBSDgrid
  % EBSD data on a hexagonal grid. In contrast to arbitrary EBSD data the
  % values are stored in a matrix.
  
  % No stored geometry. dHex + isRowAlignment could only ever express two
  % orientations, 0 and 30 degree, which is why a rotated hex grid was
  % unrepresentable; unitCell and pos hold the geometry instead, exactly as
  % @EBSDsquare does, and everything below is read off them.
  properties (Dependent = true)
    dHex            % circumradius of the hexagonal unit cell
    isRowAlignment  % true if the matrix ROWS carry the parity stagger
    offset          % +/-1, which parity the first staggered line has
    dx              % spacing along the dense direction
    dy              % spacing across it
  end

  methods
      
    function ebsd = EBSDhex(pos,rot,phaseId,phaseMap,CSList,dHex,isRowAlignment,varargin)
      % generate a hexagonal EBSD object
      %
      % Syntax
      %   EBSDhex(pos,rot,phaseId,phaseMap,CSList,'unitCell',uC)
      %   EBSDhex(pos,rot,phaseId,phaseMap,CSList,dHex,isRowAlignment)
      %
      % The unit cell is the geometry. dHex and isRowAlignment are still
      % accepted, and describe an axis aligned cell of that size; pass
      % unitCell instead to keep a measured one, which is the only way
      % to describe a rotated or sheared grid.

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

      % set up the unit cell - a supplied one is kept as it is, which is
      % what lets a rotated grid survive. Previously it was always
      % overwritten by an axis aligned hexagon built from dHex.
      if check_option(varargin,'unitCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        omega = (0:60:300)*degree + 30*isRowAlignment*degree;
        ebsd.unitCell = dHex * vector3d(cos(omega(:)), sin(omega(:)),0);
      end

      if isempty(pos)
        % built from the ARGUMENTS, not from the dependent getters below -
        % those read pos, which does not exist yet
        [cols,rows] = meshgrid(1:size(rot,2),1:size(rot,1));
        if isRowAlignment
          x = (cols-1+0.5*iseven(rows)) * dHex * sqrt(3);
          y = (rows-1) * 1.5 * dHex;
        else
          x = (cols-1) * 1.5 * dHex;
          y = (rows-1+0.5*iseven(cols)) * dHex * sqrt(3);
        end
        ebsd.pos = vector3d(x,y,0);
      end

    end

    % --------------------------------------------------------------

    function d = get.dHex(ebsd)
      d = mean(norm(ebsd.unitCell));
    end

    function tf = get.isRowAlignment(ebsd)
      tf = hexLayout(ebsd).isRowAlignment;
    end

    function of = get.offset(ebsd)
      of = hexLayout(ebsd).offset;
    end

    function d = get.dx(ebsd)
      L = hexLayout(ebsd);
      if L.isRowAlignment, d = L.dense; else, d = L.cross; end
    end

    function d = get.dy(ebsd)
      L = hexLayout(ebsd);
      if L.isRowAlignment, d = L.cross; else, d = L.dense; end
    end

    function L = hexLayout(ebsd)
      % read the staggered layout off pos, so it holds at any rotation
      %
      % A hex matrix has one dense direction, whose step is the same
      % everywhere, and one staggered direction, whose step alternates
      % between two lattice translations 60 degree apart. Which matrix index
      % is which IS the meaning of isRowAlignment, and it is visible
      % directly: on titanium the column steps run 0 0 0 0 degree while the
      % row steps run 60 120 60 120; on a flat top grid it is the other way
      % round. Asking pos rather than assuming an axis makes every answer
      % here survive a rotation, which the old sign(pos.x(2,1)-pos.x(1,1))
      % did not.

      L = struct('isRowAlignment',true,'offset',1,'dense',NaN,'cross',NaN);
      if size(ebsd,1) < 3 || size(ebsd,2) < 3
        % too small to see an alternation - fall back to the unit cell,
        % which pins the orientation for the axis aligned cases
        uC = ebsd.unitCell;
        L.isRowAlignment = diff(min(abs([uC.x(:) uC.y(:)]))) > 0;
        L.dense = ebsd.dHex * sqrt(3);
        L.cross = 1.5 * ebsd.dHex;
        return
      end

      rowStep1 = ebsd.pos(2,1) - ebsd.pos(1,1);
      rowStep2 = ebsd.pos(3,1) - ebsd.pos(2,1);
      colStep1 = ebsd.pos(1,2) - ebsd.pos(1,1);
      colStep2 = ebsd.pos(1,3) - ebsd.pos(1,2);

      tol = 1e-6 * ebsd.dHex;
      L.isRowAlignment = norm(rowStep1 - rowStep2) > tol;

      if L.isRowAlignment
        dense = colStep1;  stag = rowStep1;
        L.cross = norm(ebsd.pos(3,1) - ebsd.pos(1,1)) / 2;
      else
        dense = rowStep1;  stag = colStep1;
        L.cross = norm(ebsd.pos(1,3) - ebsd.pos(1,1)) / 2;
      end
      L.dense = norm(dense);

      % the parity: which way the first staggered line leans, measured
      % along the dense direction rather than along x or y
      L.offset = sign(dot(stag,normalize(dense)));
      if L.offset == 0, L.offset = 1; end

    end

    function [row,col] = pos2ind(ebsd,x,y)
      % nearest cell of the grid for a given position
      %
      % Syntax
      %   ind = pos2ind(ebsd,pos)
      %   [row,col] = pos2ind(ebsd,x,y)

      if nargin == 3, x = vector3d(x,y,0); end

      % Invert the grid basis instead of applying a fixed axial matrix in
      % raw x/y. The old form divided by dHex after multiplying by hard
      % coded sqrt(3)/3 and 1/3 factors, which is the inverse basis of an
      % AXIS ALIGNED hex lattice only - there was no rotation to feed it.
      % The two matrix step directions describe the lattice whatever its
      % orientation, and they are exactly the pair cube2hex expects: the
      % coefficient along the column direction is the cube x, the one along
      % the row direction the cube z.
      p0 = ebsd.pos(1,1);
      cd = ebsd.pos(1,2) - p0;
      rd = ebsd.pos(2,1) - p0;

      A = [cd.x, rd.x; cd.y, rd.y];
      d = x - p0;
      xz = A \ [d.x(:).'; d.y(:).'];

      % round in cube coordinates, which picks the nearest hexagon rather
      % than the nearest cell of the parallelogram the basis spans
      cx = xz(1,:); cz = xz(2,:); cy = -cx - cz;

      rx = round(cx); ry = round(cy); rz = round(cz);
      dx = abs(cx-rx); dy = abs(cy-ry); dz = abs(cz-rz);

      ind1 = dx>dy & dx>dz;
      ind2 = dy > dz;
      rx(ind1) = -ry(ind1) - rz(ind1); %#ok<*PROPLC>
      ry(~ind1 & ind2) = -rx(~ind1 & ind2) - rz(~ind1 & ind2);
      rz(~ind1 & ~ind2) = -rx(~ind1 & ~ind2) - ry(~ind1 & ~ind2);

      % convert to offset coordinates
      [row,col] = ebsd.cube2hex(reshape(rx,size(d)),reshape(ry,size(d)),reshape(rz,size(d)));

      if nargout < 2
        ind = ~isnan(row);
        row(ind) = sub2ind(size(ebsd),row(ind),col(ind));
      end

    end

  end
  
end
