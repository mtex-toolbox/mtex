classdef tensor < dynOption
   
  properties
    M = []        % the tensor coefficients
    rank = 0      % tensor rank
    CS = specimenSymmetry % crystal symmetry
    doubleConvention = false %
  end

  properties (Dependent = true)
    isSymmetric
    isSkewSymmetric
  end

  methods
  
    function T = tensor(M,varargin)
      % constructor
      %
      % *tensor* is the low level constructor for a *tensor* object.
      % For importing real world data you might want to use the *import_wizard*.
      %
      % Syntax
      %   T = tensor(M,CS,'name',name,'unit',unit,'propertyname',property)
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
        if check_option(varargin,'doubleConvention')
          T.doubleConvention = true;
        else
          T.doubleConvention = M.doubleConvention;
        end
        T.opt = M.opt;
        
        % extract additional properties
        varargin = delete_option(varargin,'doubleConvention');
        varargin = delete_option(varargin,'rank',1);
        T = T.setOption(varargin{:});
        return
      end

      % ensure first argument is not char
      if ischar(M), varargin = [{M},varargin]; M = []; end
      
      T.doubleConvention = check_option(varargin,'doubleConvention');
      
      if isa(M,'vector3d') % conversion from vector3d
        T.M = shiftdim(double(M),ndims(M));
        T.rank = 1;
        if isa(M,'Miller'), T.CS = M.CS; end
      
      elseif isa(M,'quaternion') % conversion from quaternion

        T.M = matrix(M);
        T.rank = 2;
  
      else % get the tensor entries

        T.M = M;
        T.rank = get_option(varargin,'rank',-1);
        if isempty(M)
          T.M = zeros([repmat(3,1,T.rank),0]);
        end
        
        % consider the case of a row vector, which is most probably a 1-rank tensor
        if ndims(T.M)==2 && size(T.M,1)==1 && size(T.M,2) > 1 && ...
            abs(T.rank) == 1
  
          disp(' ');
          warning(['I guess you want to define a rank one tensor. ' ...
            'However, a rank one tensor is always a column vector, but ' ...
            'you specified a row vector. ',...
            'I''m going to transpose you vector.']);
  
          T.M = T.M.';
          T.rank = 1;
  
        end

        % transform from voigt or Kelvin matrix representation to ordinary
        % rank four tensor
        if size(T.M,1) == 6 && size(T.M,2) == 6 && (T.rank == -1 || T.rank == 4)
          if check_option(varargin,'Kelvin')
            T.M = tensor24(T.M,2);
          else
            T.M = tensor24(T.M,T.doubleConvention);
          end
          T.rank = 4;
        elseif size(T.M,1) == 3 && size(T.M,2) == 6 && (T.rank == -1 || T.rank == 3)
          if T.rank == -1
            warning('I guess you want to specify a symmetric rank 3 tensor. Please use the option "rank" to specify the rank explicitly.')
          end
          T.M = tensor23(T.M,T.doubleConvention);
          T.rank = 3;
        elseif T.rank == -1
          % compute the rank of the tensor by finding the first dimension
          % that is different from 3
          T.rank = min([ndims(T.M),find(size(T.M)-3,1,'first')-1]);
          warning(['The rank of the tensor has been guessed to be ',...
            int2str(T.rank),'. Please specify the rank explicitely in the future']);
        end
  
      end
  
      % extract symmetry
      args = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));
      if ~isempty(args)
        T.CS = varargin{args};
        varargin(args) = [];
      end

      options = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel','noCheck'});
      options = delete_option(options,'rank',1);
      
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

    function isSym = get.isSymmetric(T)

      if T.rank == 2

        isSym = norm(T - T') ./ norm(T) < 1e-6;

      else
        
        error('not yet implemented');
        
      end
      

    end


  end
  
  methods (Static = true)

    T = load(fname,varargin)
    
    function T = eye(varargin)
      r = get_option(varargin,'rank',2);
      [cs,varargin] = getClass(varargin,'symmetry');
      varargin = delete_option(varargin,'rank',1);
      switch r
        case 2
          T = tensor(repmat(eye(3),[1,1,varargin{:}]),'rank',2);
        case 4
          M = diag([1,1,1,0.5,0.5,0.5]);
          T = tensor(repmat(M,[1,1,varargin{:}]),'rank',4);
        otherwise
          error('Not supported!')
      end
      if ~isempty(cs), T.CS = cs; end
    end
    
    function T = zeros(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank',1);
      [cs,varargin] = getClass(varargin,'symmetry');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(zeros(d),'rank',r);
      if ~isempty(cs), T.CS = cs; end
    end
    
    function T = ones(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank',1);
      [cs,varargin] = getClass(varargin,'symmetry');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(ones(d),'rank',r);
      if ~isempty(cs), T.CS = cs; end
    end
    
    function T = nan(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank',1);
      [cs,varargin] = getClass(varargin,'symmetry');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(nan(d),'rank',r);
      if ~isempty(cs), T.CS = cs; end
    end
    
    function T = rand(varargin)
      r = get_option(varargin,'rank',2);
      varargin = delete_option(varargin,'rank',1);
      [cs,varargin] = getClass(varargin,'symmetry');
      d = [repmat(3,1,r),varargin{:},1];
      T = tensor(rand(d),'rank',r);
      if ~isempty(cs), T.CS = cs; end
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
      
      eps = tensor(eps,'rank',3,'name','Levi Cevita');
      
    end
  end
  
end
