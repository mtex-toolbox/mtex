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
%  xyz   - 3 x N matrix (one vector per column, gives a 1 x N list) or
%          N x 3 matrix (one vector per row, gives an N x 1 list)
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
    how2plot = plottingConvention.default
  end
    
  properties (Dependent = true)
    theta   % polar angle
    rho     % azimuth angle
    resolution % mean distance between the points on the sphere
    plottingConvention
  end

  methods
    
    function v = vector3d(varargin)
      % constructor of the class vector3d
      
      if nargin >=3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
        
        v.x = varargin{1};
        v.y = varargin{2};
        v.z = varargin{3};
      
      elseif nargin == 0

        v.how2plot = plottingConvention.default;

      else
        if isa(varargin{1},'vector3d') % copy-constructor
          
          v.x = varargin{1}.x;
          v.y = varargin{1}.y;
          v.z = varargin{1}.z;
          v.antipodal = varargin{1}.antipodal;
          v.isNormalized = varargin{1}.isNormalized;
          v.opt = varargin{1}.opt;
          v.how2plot = varargin{1}.how2plot;
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

            % a matrix of coordinates keeps the row / column correspondence
            % of the three argument form: a 3 x N matrix holds one vector
            % per column and gives a 1 x N list, an N x 3 matrix holds one
            % per row and gives an N x 1 list - the same reading byXYZ uses.
            % Previously anything that was not 3 x N was transposed into it,
            % so an N x 3 matrix came back as a ROW of N vectors (#2145).
            if size(xyz,1) == 3 && size(xyz,2) == 3
              % satisfies both readings and nothing in the data says which
              warning('MTEX:vector3d:ambiguousMatrix',...
                ['A 3 x 3 matrix of coordinates is ambiguous - it is read '...
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
                ['A vector3d is built from a 3 x N or an N x 3 matrix of '...
                'coordinates, not from a %s one.'],mat2str(size(xyz)));
            end

          end
          v.how2plot = plottingConvention.default;
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
       
       v.how2plot = getClass(varargin,'plottingConvention');
       if isempty(v.how2plot), v.how2plot = plottingConvention.default; end

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

    function v = set.how2plot(v,pC)
      % accept a string like 'y↑→x' as a shortcut for the convention
      if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
      v.how2plot = pC;
    end

    % ------- to be removed ------
    function pC = get.plottingConvention(v)
      pC = v.how2plot;
    end

    function v = set.plottingConvention(v,pC)
      v.how2plot = pC;
    end
    % -------------------------------
    
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
      if size(d,2) == 3
        v = vector3d(d(:,1),d(:,2),d(:,3),varargin{:});
      elseif size(d,2) == 2
        % zeros(n,1) and not the scalar 0: the constructor repairs a scalar
        % coordinate by repmat-ing it to the size of the others, and for an
        % EMPTY d there is no non singular size to repmat to - a scalar z
        % then stays 1 x 1 against a 0 x 1 x and y and the constructor
        % errors with "Coordinates have different size"
        v = vector3d(d(:,1),d(:,2),zeros(size(d,1),1),varargin{:});
      else
        % anything else used to silently keep columns 1 and 2 and drop the
        % rest, which is how an n x 4 built by a caller that had already
        % appended a z column lost that column without a word
        error('MTEX:vector3d:wrongSize',...
          ['vector3d.byXYZ reads one vector per row, so it takes an N x 3 '...
          'or an N x 2 matrix of coordinates, not a %s one.'],mat2str(size(d)));
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

      if isempty(v.how2plot), v.how2plot = plottingConvention.default; end

    end
    
  end
end
