classdef vector3d < dynOption
%
% The class vector3d describes three dimensional vectors, given by
% their coordinates x, y, z and allows to calculate with them as
% comfortable as with real numbers.
%
% Syntax
%   v = vector3d(x,y,z)
%   v = vector3d(x,y,z,'antipodal')
%   v = vector3d.byPolar(theta,rho)
%
% Input
%  x,y,z - cart. coordinates
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
    plottingConvention = plottingConvention
  end
    
  properties (Dependent = true)
    theta   % polar angle
    rho     % azimuth angle
    resolution % mean distance between the points on the sphere
  end
  
  methods
    
    function v = vector3d(varargin)
      % constructor of the class vector3d
      
      if nargin >=3 && isnumeric(varargin{1})
        
        v.x = varargin{1};
        v.y = varargin{2};
        v.z = varargin{3};
      
      elseif nargin == 0
      elseif nargin <= 2
        if isa(varargin{1},'vector3d') % copy-constructor
          
          v.x = varargin{1}.x;
          v.y = varargin{1}.y;
          v.z = varargin{1}.z;
          v.antipodal = varargin{1}.antipodal;
          v.isNormalized = varargin{1}.isNormalized;
          v.opt = varargin{1}.opt;
          return
          
        elseif isa(varargin{1},'float')
          xyz = varargin{1};

          if numel(xyz) == 2
            v.x = xyz(1);
            v.y = xyz(2);
            v.z = 0;
          else
            if size(xyz,1) ~= 3, xyz = xyz.'; end
            v.x = xyz(1,:);
            v.y = xyz(2,:);
            v.z = xyz(3,:);
          end
        else
          error('wrong type of argument');
        end       
      elseif ischar(varargin{1})
        
        if strcmp(varargin{1},'polar')
          
          sy = sin(varargin{2});
          v.x = sy .* cos(varargin{3});
          v.y = sy .* sin(varargin{3});
          v.z = cos(varargin{2});
          
        else
          
          theta = get_option(varargin,{'theta','azimuth'});
          rho = get_option(varargin,{'rho','polar'});
          
          v.x = sin(theta).*cos(rho);
          v.y = sin(theta).*sin(rho);
          v.z = cos(theta);
          
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
       
       v.plottingConvention = getClass(varargin,'plottingConvention',v.plottingConvention);

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
      v = vector3d(real(v.x),real(v.y),real(v.z));
    end

    function v = imag(v)
      v = vector3d(imag(v.x),imag(v.y),imag(v.z));
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
      if size(d,2) == 3
        v = vector3d(d(:,1),d(:,2),d(:,3),varargin{:});
      else
        v = vector3d(d(:,1),d(:,2),0,varargin{:});
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
    
    
  end
end
