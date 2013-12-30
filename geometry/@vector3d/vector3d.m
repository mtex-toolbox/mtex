classdef vector3d < dynOption
  
  properties 
    x = []; % x coordinate
    y = []; % y coordinate
    z = []; % z coordinate
    antipodal = false;
  end
    
  
  methods
    
    function v = vector3d(x,y,z,varargin)
      % Constructor
      % Syntax
      %  v = vector3d(1,2,3)
      %
      %
      %  x,y,z - cart. coordinates
      %  v     - @vector3d
      %  empty -> vector3d(0,0,0)

      if nargin == 0
      elseif nargin ==1
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
        
      elseif strcmp(x,'polar')
        
        v.x = sin(y).*cos(z);
        v.y = sin(y).*sin(z);
        v.z = cos(y);
                
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
        v = set(v,'resolution',get_option(varargin,'resolution'));
      end
      
      % normalize
      if nargin > 3 && check_option(varargin,'normalize'), v = v ./ norm(v); end
      
    end
     
  end
end
