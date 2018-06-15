classdef tensor < dynOption
   
  properties
    M = []        % the tensor coefficients
    rank = 0      % tensor rank
    CS = specimenSymmetry % crystal symmetry
    doubleConvention = false %
  end
  
  methods
  
    function T = tensor(M,varargin)
      % constructor
      %
      % *tensor* is the low level constructor for a *tensor* object.
      % For importing real world data you might want to use the *import_wizard*.
      %
      % Syntax
      %  T = tensor(M,CS,'name',name,'unit',unit,'propertyname',property)
      %
      % Input
      %  M  - matrix of tensor entries
      %  CS - crystal @symmetry
      %
      % Options
      %  rank - rank of the tensor
      %  unit - physical unit of the entries
      %  name - name of the tensor
      %
      % See also
      % ODF/calcTensor EBSD/calcTensor

      if nargin == 0
        
        return
      
      elseif isa(M,'tensor') % copy constructor
        T.M = M.M;
        T.rank = M.rank;
        T.CS = M.CS;
        T.doubleConvention = M.doubleConvention;
        T.opt = M.opt;
        
        % extract additional properties
        varargin = delete_option(varargin,'doubleConvention');
        T = T.setOption(varargin{:});
        return
      end
      
      T.doubleConvention = check_option(varargin,'doubleConvention');
      
      if isa(M,'vector3d') % conversion from vector3d
        T.M = shiftdim(double(M),ndims(M));
        r = 1;
        if isa(M,'Miller'), T.CS = M.CS; end
      
      elseif isa(M,'quaternion') % conversion from quaternion

        T.M = matrix(M);
        r = 2;
  
      else         % get the tensor entries

        T.M = M;

        % consider the case of a row vector, which is most probably a 1-rank tensor
        if ndims(T.M)==2 && size(T.M,1)==1 && size(T.M,2) > 1 && ...
            ~check_option(varargin,'rank')
  
          disp(' ');
          warning(['I guess you want to define a rank one tensor. ' ...
            'However, a rank one tensor is always a column vector, but ' ...
            'you specified a row vector. ',...
            'I''m going to transpose you vector.']);
  
          T.M = T.M.';
  
        end

        % transform from voigt matrix representation to ordinary rank four tensor
        if size(T.M,1) == 6 && size(T.M,2) == 6
          T.M = tensor24(T.M,T.doubleConvention);
        elseif numel(T.M) == 18
          T.M = tensor23(T.M,T.doubleConvention);
        end

        % compute the rank of the tensor by finding the last dimension
        % that is length grater then one
        r = max([1,find(size(T.M)-1,1,'last')]);
  
      end
  
      T.rank    = get_option(varargin,'rank',r);
      varargin = delete_option(varargin,'rank',1);

      % extract symmetry
      args = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));
      if ~isempty(args)
        T.CS = varargin{args};
        varargin(args) = [];
      end

      options = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel','noCheck'});
      
      % extract properties
      T = T.setOption(options{:});
         
      % check symmetry
      if ~check_option(varargin,'noCheck') && ~checkSymmetry(T)
        T = symmetrise(T);
      end
    end
          
    function [varargout] = calcTensor(obj,varargin)
      [varargout{1:nargout}] = obj.calcTensor(varargin{:});
    end
    
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
  end
  
  methods (Static = true)

    function T = load(varargin)
      T = loadTensor(varargin{:});
    end

    function T = eye(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank');
      switch r
        case 2
          T = tensor(repmat(eye(3),[1,1,varargin{:}]),'rank',2);
        case 4
          M = diag([1,1,1,0.5,0.5,0.5]);
          T = tensor(repmat(M,[1,1,varargin{:}]),'rank',4);
        otherwise
          error('Not supported!')
      end
    end
    
    function T = zeros(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(zeros(d),'rank',r);
    end
    
    function T = ones(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(ones(d),'rank',r);
    end
    
    function T = nan(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(nan(d),'rank',r);
    end
    
    function T = rand(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(rand(d),'rank',r);
    end
    
    function eps = leviCivita
      % the Levi Civita permutation tensor
      
      eps = zeros(3,3,3);
      eps(1,2,3) = 1;
      eps(3,1,2) = 1;
      eps(2,3,1) = 1;
      
      eps(1,3,2) = -1;
      eps(3,2,1) = -1;
      eps(2,1,3) = -1;
      
      eps = tensor(eps,'name','Levi Cevita');
      
    end
  end
  
end
