classdef quaternion
  % TODO: the syntax quanternion(r,2:20) was allowed
  
  
  properties
    a % real part
    b % * i
    c % * j
    d % * k
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
              
              D = varargin{1};
              
              [q.a q.b q.c q.d] = deal(D(1,:),D(2,:),D(3,:),D(4,:));
              
              s = size(D);
              s = [1 s(2:ndims(D))];
              
              q = reshape(q,s);
              
            case 2
              
              if length(varargin{1}) ~= 1
                q.a = varargin{1};
              else
                q.a = repmat(varargin{1},size(varargin{2}));
              end
              [q.b,q.c,q.d] = double(varargin{2});
              
            case 4
              
              [q.a q.b q.c q.d] = deal(varargin{:});
              
          end

          
          if any(nthroot(size(q.a).*size(q.b).*size(q.c).*size(q.d),4) ~= size(q))
            
            s = [size(q.a); size(q.b); size(q.c); size(q.d)];            
            n = prod(s,2);
            if all((n == 1) | max(n) == n)
              s = max(s);
              if n(1) == 1, q.a = repmat(q.a,s);end
              if n(2) == 1, q.b = repmat(q.b,s);end
              if n(3) == 1, q.c = repmat(q.c,s);end
              if n(4) == 1, q.d = repmat(q.d,s);end
              
            else
              error('matrix dimensions do not agree');
            end
            
          end
          
          
      end
      
    end
  end
  
end
