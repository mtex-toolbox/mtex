classdef vector3d < dynOption
%
% The class |vector3d| describes three dimensional vectors, given by
% their coordinates x, y, z and allows to calculate with them as
% comfortable as with real numbers.
%
% Syntax
%   v = vector3d(x,y,z)
%   v = vector3d(x,y,z,'antipodal')
%   v = vector3d(xyz)
%   v = vector3d.byPolar(theta,rho)
%
% Input
%  x,y,z - cart. coordinates
%  xyz   - 3 × N matrix (one vector per column, gives a 1 × N list) or
%          N × 3 matrix (one vector per row, gives an N × 1 list)
%
% Output
%  v - @vector3d
%
% Flags
%  antipodal - <VectorsAxes.html consider vector as an axis>
%
% Class Properties
%  x, y, z      - cart. coordinates
%  isNormalized - whether the vector is a direction
%  antipodal    - <VectorsAxes.html whether the vector is an axis>
%
% Dependent Class Properties
%  theta      - polar angle in radiant
%  rho        - azimuth angle in radiant
%  resolution - mean distance between the points on the sphere
%  xyz        - cart. coordinates as matrix
%
% Derived Classes
%  @Miller - crystal directions
%  @S2Grid - spherical grid
%
% See also
% VectorDefinition VectorsOperations VectorsAxes VectorsImport VectorsExport

  properties
    x = []; % x coordinate
    y = []; % y coordinate
    z = []; % z coordinate
    antipodal = false;
    isNormalized = false;

    % how the coordinates are named when the vector is written down: xyz for
    % a direction that has no index basis, hkl / uvw and their four index
    % forms for one given in a crystal frame (ADR 0008 rule 6)
    dispStyle = MillerConvention.xyz
  end

  properties (Hidden = true)
    % the referenceFrame this vector is expressed in, empty = frame-free
    framePrivate = []
  end

  properties (Dependent = true)
    theta   % polar angle
    rho     % azimuth angle
    resolution % mean distance between the points on the sphere
    frame    % the referenceFrame this vector is expressed in
    how2plot % plotting convention - read only
    % a convention belongs to a reference frame, see plottingConvention.default

    % the crystal indices, defined only for a direction in a crystal frame -
    % ask isCrystalDirection before reading them
    CS          % the crystal frame these indices are written in
    convention  % same as dispStyle
    coordinates % the coordinates in the convention set above
    lattice     % the lattice type of the crystal frame
    hkl         % reciprocal coordinates
    hkil        % reciprocal coordinates, four index
    h
    k
    i
    l
    uvw         % direct coordinates
    UVTW        % direct coordinates, Weber indices
    u
    v
    w
    U
    V
    T
    W
  end

  methods
    
    function v = vector3d(varargin)
      % constructor of the class vector3d
      
      if nargin >=3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
        
        v.x = varargin{1};
        v.y = varargin{2};
        v.z = varargin{3};
      
      elseif nargin == 0

        % frame-free - the plotting convention resolves against the
        % session default at render time

      else
        if isa(varargin{1},'vector3d') % copy-constructor

          v.x = varargin{1}.x;
          v.y = varargin{1}.y;
          v.z = varargin{1}.z;
          v.antipodal = varargin{1}.antipodal;
          v.isNormalized = varargin{1}.isNormalized;
          v.opt = varargin{1}.opt;
          % the private slot, not the resolved frame
          v.framePrivate = varargin{1}.framePrivate;
          return
          
        elseif isa(varargin{1},'float')
          xyz = varargin{1};

          if numel(xyz) == 2

            v.x = xyz(1);
            v.y = xyz(2);
            v.z = 0;

          elseif isempty(xyz) && size(xyz,2) ~= 3

            v.x = []; v.y = []; v.z = [];

          else

            % a 3 × N matrix gives a 1 × N list, an N × 3 matrix an N × 1 list
            if size(xyz,1) == 3 && size(xyz,2) == 3
              % satisfies both readings and nothing in the data says which
              warning('MTEX:vector3d:ambiguousMatrix',...
                ['A 3 × 3 matrix of coordinates is ambiguous - it is read '...
                'as three vectors given by its COLUMNS. Use '...
                'vector3d.byXYZ(xyz) to read it by rows instead.']);
            end

            if size(xyz,1) == 3
              v.x = xyz(1,:);
              v.y = xyz(2,:);
              v.z = xyz(3,:);
            elseif size(xyz,2) == 3
              v.x = xyz(:,1);
              v.y = xyz(:,2);
              v.z = xyz(:,3);
            else
              error('MTEX:vector3d:wrongSize',...
                ['A vector3d is built from a 3 × N or an N × 3 matrix of '...
                'coordinates, not from a %s one.'],mat2str(size(xyz)));
            end

          end
        else
          error('wrong type of argument');
        end
               
      end

      % ----------- check for equal size ------------------------
      if numel(v.x) ~= numel(v.y) || (numel(v.x) ~= numel(v.z))
  
        % find non singular size
        if numel(v.x) > 1
          s = size(v.x);
        elseif numel(v.y) > 1
          s = size(v.y);
        else
          s = size(v.z);
        end
  
        % try to correct
        if isscalar(v.x), v.x = repmat(v.x,s);end
        if isscalar(v.y), v.y = repmat(v.y,s);end
        if isscalar(v.z), v.z = repmat(v.z,s);end
  
        % check again
        if numel(v.x) ~= numel(v.y) || (numel(v.x) ~= numel(v.z))
          error('MTEX:Vector3d','Coordinates have different size.');
        end
      end

      % ------------------ options ------------------------------
      
      if nargin > 1
        
        % antipodal
        v.antipodal = check_option(varargin,'antipodal');
      
        % resolution
        if check_option(varargin,'resolution')
          v = v.setOption('resolution',get_option(varargin,'resolution'));
        end
      
        % normalize
       if check_option(varargin,'normalize'), v = normalize(v); end

       fr = getClass(varargin,'referenceFrame');
       if ~isempty(fr), v.frame = fr; end

       pC = getClass(varargin,'plottingConvention');
       if ~isempty(pC), v.frame = specimenFrame.frameFor(pC); end

      end
    end
  
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
    
    function rho = get.rho(v)
      try
        rho = v.opt.rho;
      catch
        rho = atan2(v.y,v.x);
      end
    end
    
    function theta = get.theta(v)
      try
        theta = v.opt.theta;
      catch
        theta = acos(v.z./v.norm);
      end
    end

    function pC = get.how2plot(v)
      % the convention of the frame, or the session default - resolved
      % live, so frame-free data follows whatever the default becomes;
      % only frames carry conventions
      pC = [];
      if ~isempty(v.frame), pC = v.frame.how2plot; end
      if isempty(pC), pC = plottingConvention.default; end
    end


    function fr = get.frame(v)
      fr = getFrame(v);
    end

    function v = set.frame(v,fr)
      v = setFrame(v,fr);
    end

    function fr = getFrame(v)
      fr = v.framePrivate;
    end

    function v = setFrame(v,fr)
      assert(isempty(fr) || isa(fr,'referenceFrame'), ...
        'The frame of a vector3d has to be a referenceFrame or empty.');
      v.framePrivate = fr;
    end


    % --- the crystal indices, when the frame is a crystal one ------------

    function cs = get.CS(v)
      % ask getFrame, not the property - a subclass may derive its frame
      cs = v.frame;
      if ~isa(cs,'crystalFrame'), cs = crystalFrame.empty; end
    end

    function v = set.CS(v,cs)
      % assigning a crystal frame keeps the INDICES, so the Cartesian
      % coordinates are recomputed - which is what distinguishes it from
      % assigning frame, where the components are what is kept
      if isa(v.framePrivate,'crystalFrame') && v.framePrivate ~= cs
        coord = v.coordinates;
        v.framePrivate = cs;
        v.coordinates = coord;
      else
        v.framePrivate = cs;
      end
    end

    function l = get.lattice(v)
      cs = v.CS;
      if isempty(cs), l = latticeType.none; else, l = cs.lattice; end
    end

    function out = get.convention(v), out = v.dispStyle; end
    function v = set.convention(v,dS), v.dispStyle = dS; end

    function c = get.coordinates(v), c = v.(char(v.dispStyle)); end
    function v = set.coordinates(v,c), v.(char(v.dispStyle)) = c; end

    function hkl = get.hkl(v)
      M = double(axesDual(v.CS));
      hkl = (M \ v.xyz.').';
    end

    function hkil = get.hkil(v)
      hkl = v.hkl;
      hkil = [hkl(:,1:2),-hkl(:,1)-hkl(:,2),hkl(:,3)];
    end

    function h = get.h(v), h = v.hkl(:,1); end
    function k = get.k(v), k = v.hkl(:,2); end
    function i = get.i(v), i = v.hkil(:,3); end
    function l = get.l(v), l = v.hkl(:,end); end

    function v = set.hkl(v,hkl)
      % hkl must have the format [h,k,l] or [h k i l]
      hkl = hkl(:,[1:2,end]);

      M = axesDual(v.CS).xyz;
      v.x = hkl * M(:,1);
      v.y = hkl * M(:,2);
      v.z = hkl * M(:,3);

      if v.lattice.isTriHex
        v.dispStyle = 'hkil';
      else
        v.dispStyle = 'hkl';
      end
    end

    function v = set.hkil(v,hkil), v.hkl = hkil; end

    function v = set.h(v,h), v.hkl = [h v.k v.l]; end
    function v = set.k(v,k), v.hkl = [v.h k v.l]; end
    function v = set.l(v,l), v.hkl = [v.h v.k l]; end

    function uvw = get.uvw(v)
      M = double(v.CS.axes);
      uvw = (M \ double(v)).';
    end

    function UVTW = get.UVTW(v)
      % U = 2u - v, V = 2v - u, T = -(u+v), W = 3w
      uvw = v.uvw; %#ok<*PROP>
      UVTW = [2*uvw(:,1)-uvw(:,2), 2*uvw(:,2)-uvw(:,1), ...
        -uvw(:,1)-uvw(:,2), 3*uvw(:,3)];
    end

    function u = get.u(v), u = v.uvw(:,1); end
    function vv = get.v(v), vv = v.uvw(:,2); end
    function w = get.w(v), w = v.uvw(:,3); end
    function U = get.U(v), U = v.UVTW(:,1); end
    function V = get.V(v), V = v.UVTW(:,2); end
    function T = get.T(v), T = v.UVTW(:,3); end
    function W = get.W(v), W = v.UVTW(:,4); end

    function v = set.uvw(v,uvw)
      % uvw must be of format [u v w] or [u v t w]
      if size(uvw,2) == 4, error('Use UVTW to set four Miller indice!'); end

      M = v.CS.axes.xyz;
      v.x = uvw * M(:,1);
      v.y = uvw * M(:,2);
      v.z = uvw * M(:,3);

      v.dispStyle = 'uvw';
    end

    function v = set.UVTW(v,UVTW)
      % U = 2u - v, V = 2v - u, T = -(u+v), W = 3w
      if size(UVTW,2) == 4
        v.uvw = [UVTW(:,1)-UVTW(:,3),UVTW(:,2)-UVTW(:,3),UVTW(:,4)]./3;
      elseif v.lattice.isTriHex
        v.uvw = [2*UVTW(:,1) + UVTW(:,2),2*UVTW(:,2) + UVTW(:,1),UVTW(:,3)]./3;
      end

      v.dispStyle = 'UVTW';
    end

    function v = set.u(v,u), v.uvw = [u v.v v.w]; end
    function v = set.v(v,vv), v.uvw = [v.u vv v.w]; end
    function v = set.w(v,w), v.uvw = [v.u v.v w]; end
    function v = set.U(v,U), v.UVTW = [U v.V v.T v.W]; end
    function v = set.V(v,V), v.UVTW = [v.U V v.T v.W]; end
    function v = set.T(v,T), v.UVTW = [v.U v.V T v.W]; end
    function v = set.W(v,W), v.UVTW = [v.U v.V v.T W]; end

    function xyz = xyz(v)
      xyz = [v.x(:),v.y(:),v.z(:)];      
    end

    function xy = xy(v)
      xy = [v.x(:),v.y(:)];      
    end
    
    function res = get.resolution(v)
      
      if v.isOption('resolution')
        res = v.getOption('resolution');
      elseif length(v) <= 4
        res = 2*pi;
      elseif length(v) > 50000
        res = sqrt(40000 / length(v) / (1 + v.antipodal)) * degree;
      else
        try
          a = calcVoronoiArea(v);
          res = sqrt(median(a));
          assert(res>0);
        catch
            res = 2*pi;
        end        
      end
    end
    
    function v = set.resolution(v,res)
      
      v = v.setOption('resolution',res);
      
    end

    function v = setXYZ(v,x,y,z)
      v.x = x;
      v.y = y;
      v.z = z;
    end

    
    function b = isnan(v)
      b = isnan(v.x) | isnan(v.y) | isnan(v.z);
    end
    
    function b = isinf(v)
      b = isinf(v.x) | isinf(v.y) | isinf(v.z);
    end
    
    function b = isfinite(v)
      b = ~(isinf(v) | isnan(v));
    end

    function b = isreal(v)
      b = isreal(v.x) & isreal(v.y) & isreal(v.z);
    end

   function v = real(v)
      v.x = real(v.x);
      v.y = real(v.y);
      v.z = real(v.z);
    end

    function v = imag(v)
      v.x = imag(v.x);
      v.y = imag(v.y);
      v.z = imag(v.z);
    end
    
  end
  
  methods (Static = true)
    
    v = nan(varargin)
    v = ones(varargin)
    v = zeros(varargin)
    v = rand(varargin)
    v = byPolar(polarAngle,azimuthAngle,varargin)
    [v,interface,options] = load(fname,varargin)

    function v = byXYZ(d,varargin)
      % read a matrix of coordinates by ROWS - one vector per row
      %
      % Syntax
      %   v = vector3d.byXYZ([x(:) y(:) z(:)])
      %   v = vector3d.byXYZ([x(:) y(:)])       % z = 0
      %
      if isequal(size(d),[0 0])
        % [] says nothing about a width, an empty evaluation returns it
        v = vector3d(zeros(0,3),varargin{:});
      elseif size(d,2) == 3
        v = vector3d(d(:,1),d(:,2),d(:,3),varargin{:});
      elseif size(d,2) == 2
        % zeros(n,1) and not the scalar 0, which an empty d has no size to repmat to
        v = vector3d(d(:,1),d(:,2),zeros(size(d,1),1),varargin{:});
      else
        % anything else used to silently keep columns 1 and 2 and drop the rest
        error('MTEX:vector3d:wrongSize',...
          ['vector3d.byXYZ reads one vector per row, so it takes an N × 3 '...
          'or an N × 2 matrix of coordinates, not a %s one.'],mat2str(size(d)));
      end
    end

    function v = X(varargin)
      % the vector (1,0,0)
      %
      % Syntax
      %   x = vector3d.X % returns a single vector (1,0,0)
      %   x = vector3d.X(3,1) % returns 3 vectors (1,0,0)
      
      s = varargin(cellfun(@isnumeric,varargin));
      x = ones(s{:});
      v = vector3d(x,0,0,varargin{:});
    end
    
    function v = Y(varargin)
      s = varargin(cellfun(@isnumeric,varargin));
      x = ones(s{:});
      v = vector3d(0,x,0,varargin{:});
    end
    
    function v = Z(varargin)
      s = varargin(cellfun(@isnumeric,varargin));
      x = ones(s{:});
      v = vector3d(0,0,x,varargin{:});
    end    

    function v = loadobj(v)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions

      % MATLAB hands over a struct when the saved fields do not match the class
      if ~isa(v,'vector3d'), v = vector3d.fromStruct(vector3d,v); end

      % re-intern a deserialized frame against the register, see referenceFrame/reintern
      if ~isempty(v.framePrivate)
        v.framePrivate = referenceFrame.reintern(v.framePrivate);
      end

    end

    function v = fromStruct(v,s)
      % fill the vector3d part of v from a struct handed to loadobj
      %
      % A SUBCLASS has to pass an object of its own class here. MATLAB
      % hands loadobj a raw struct whenever the saved property set no
      % longer matches the class definition - which is what loading a file
      % written by an earlier MTEX looks like - and rebuilding a plain
      % vector3d from it silently downgrades the class. An @S2Grid that
      % comes back as a list of vectors has lost the very methods it
      % exists for: @S2Grid/getdata is then undefined, and SO3Grid/dot_outer
      % fails deep inside the evaluation of any ODF loaded from such a file.
      %
      % Syntax
      %   v = vector3d.fromStruct(S2Grid(...),s)
      %
      % See also
      % vector3d/loadobj S2Grid/loadobj

      [v.x,v.y,v.z] = deal(s.x,s.y,s.z);
      if isfield(s,'antipodal'),    v.antipodal = s.antipodal; end
      if isfield(s,'isNormalized'), v.isNormalized = s.isNormalized; end
      if isfield(s,'opt') && isstruct(s.opt), v.opt = s.opt; end
      if isfield(s,'framePrivate'), v.framePrivate = s.framePrivate; end

    end

  end
end
