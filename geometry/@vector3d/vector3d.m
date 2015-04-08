classdef vector3d < dynOption
  
  properties 
    x = []; % x coordinate
    y = []; % y coordinate
    z = []; % z coordinate
    antipodal = false;
  end
    
  properties (Dependent = true)
    theta   % polar angle
    rho     % azimuth angle
    resolution % mean distance between the points on the sphere
  end
  
  methods
    
    function v = vector3d(x,y,z,varargin)
      % Constructor
      %
      % Syntax
      %   v = vector3d(x,y,z)
      %
      % Input
      %  x,y,z - cart. coordinates
      %
      % Flags
      %   antipodal - consider vector as an axis and not as an direction
      %
      % See also
      % AxialDirectional

      if nargin == 0
      elseif nargin <= 2
        if isa(x,'vector3d') % copy-constructor
          [v.x,v.y,v.z] = double(x);
          v.antipodal = x.antipodal;
          v.opt = x.opt;
          return
        elseif isa(x,'double')
          if all(size(x) == [1,3])
            x = x.';
          end
          v.x = x(1,:);
          v.y = x(2,:);
          v.z = x(3,:);
        else
          error('wrong type of argument');
        end
        
      elseif nargin >=3 && isnumeric(x) && isnumeric(y) && isnumeric(z)
        
        v.x = x;
        v.y = y;
        v.z = z;
        
      elseif ischar(x)
        
        if strcmp(x,'polar')
        
          v.x = sin(y).*cos(z);
          v.y = sin(y).*sin(z);
          v.z = cos(y);
          
        else
          
          theta = get_option([{x,y,z},varargin],{'theta','azimuth'});
          rho = get_option([{x,y,z},varargin],{'rho','polar'});
          
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
      
      % antipodal
      v.antipodal = check_option(varargin,'antipodal');
      
      % resolution
      if check_option(varargin,'resolution')
        v = v.setOption('resolution',get_option(varargin,'resolution'));
      end
      
      % normalize
      if nargin > 3 && check_option(varargin,'normalize'), v = v ./ norm(v); end
      
    end
  
    function rho = get.rho(v)
      rho = getRho(v);
    end
    
    function theta = get.theta(v)
      theta = getTheta(v);
    end
    
    function res = get.resolution(v)
      
      if v.isOption('resolution')
        res = v.getOption('resolution');
      elseif length(v) <= 4
        res = 2*pi;
      elseif length(v) > 50000
        res = 1*pi;
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
  end
end
