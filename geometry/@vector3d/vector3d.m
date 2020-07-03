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
%  rho        - azimuthal angle in radiant
%  resolution - mean distance between the points on the sphere
%  xyz        - cart. coordinates as matrix
%
% Derived Classes
%  @Miller - crystal directions
%  @S2Grid - sphercial grid
%
% See also
% VectorDefinition VectorsOperations VectorsAxes VectorsImport VectorsExport

  properties 
    x = []; % x coordinate
    y = []; % y coordinate
    z = []; % z coordinate
    antipodal = false;
    isNormalized = false;
  end
    
  properties (Dependent = true)
    theta   % polar angle
    rho     % azimuth angle
    resolution % mean distance between the points on the sphere
    xyz
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
        if strcmp(class(varargin{1}),'vector3d') %#ok<STISA>
          
          v = varargin{1};
          
        elseif isa(varargin{1},'vector3d') % copy-constructor
          
          v.x = varargin{1}.x;
          v.y = varargin{1}.y;
          v.z = varargin{1}.z;
          v.antipodal = varargin{1}.antipodal;
          v.isNormalized = varargin{1}.isNormalized;
          v.opt = varargin{1}.opt;
          return
          
        elseif isa(varargin{1},'double')
          xyz = varargin{1};
          if all(size(xyz) == [1,3])
            xyz = xyz.';
          end
          v.x = xyz(1,:);
          v.y = xyz(2,:);
          v.z = xyz(3,:);
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
        if numel(v.x) == 1, v.x = repmat(v.x,s);end
        if numel(v.y) == 1, v.y = repmat(v.y,s);end
        if numel(v.z) == 1, v.z = repmat(v.z,s);end
  
        % check again
        if numel(v.x) ~= numel(v.y) || (numel(v.x) ~= numel(v.z))
          error('MTEX:Vector3d','Coordinates have different size.');
        end
      end

      % ------------------ options ------------------------------
      
      if nargin > 3
        
        % antipodal
        v.antipodal = check_option(varargin,'antipodal');
      
        % resolution
        if check_option(varargin,'resolution')
          v = v.setOption('resolution',get_option(varargin,'resolution'));
        end
      
        % normalize
       if check_option(varargin,'normalize'), v = normalize(v); end
       
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
    
    function xyz = get.xyz(v)
      
      xyz = [v.x(:),v.y(:),v.z(:)];
      
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
    
  end
  
  methods (Static = true)
    
    v = nan(varargin)
    v = ones(varargin)
    v = zeros(varargin)
    v = rand(varargin)
    v = byPolar(polarAngle,azimuthAngle,varargin)
    [v,interface,options] = load(fname,varargin)
    
    function v = X(varargin)
      % the vector (1,0,0)
      %
      % Syntax
      %   x = vector3d.X % returns a single vector (1,0,0)
      %   x = vector3d.X(3,1) % returns 3 vectors (1,0,0)
      
      x = ones(varargin{:});
      v = vector3d(x,0,0);
    end
    
    function v = Y(varargin)
      x = ones(varargin{:});
      v = vector3d(0,x,0);
    end
    
    function v = Z(varargin)
      x = ones(varargin{:});
      v = vector3d(0,0,x);
    end    
    
    
  end
end
