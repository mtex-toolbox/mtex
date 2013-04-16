classdef quaternion
  % TODO: the syntax quanternion(r,2:20) was allowed
  
  
  properties
    a = []; % real part
    b = []; % * i
    c = []; % * j
    d = []; % * k
  end
  
  methods
    function q = quaternion(varargin) 

      if nargin == 0, return;end
      
      switch class(varargin{1})
        
        % copy constructor
        case {'quaternion','rotation','symmetry','SO3Grid','orientation'}
        
          q.a = varargin{1}.a;
          q.b = varargin{1}.b;
          q.c = varargin{1}.c;
          q.d = varargin{1}.d;
          
        case 'vector3d'
    
          q.a = zeros(size(varargin{1}));
          [q.b,q.c,q.d] = double(varargin{1});
          
        case 'double'
        
          switch nargin
            
            case 1
             
              q.a = varargin{1}(1,:,:,:,:,:,:);
              q.b = varargin{1}(2,:,:,:,:,:,:);
              q.c = varargin{1}(3,:,:,:,:,:,:);
              q.d = varargin{1}(4,:,:,:,:,:,:);    
              
            case 2
              
              if length(varargin{1}) ~= 1
                q.a = varargin{1};
              else
                q.a = repmat(varargin{1},size(varargin{2}));
              end
              [q.b,q.c,q.d] = double(varargin{2});
              
            case 4
              
              q.a = varargin{1};
              q.b = varargin{2};
              q.c = varargin{3};
              q.d = varargin{4};
                            
          end
          
      end
      
    end
  end
  
end
