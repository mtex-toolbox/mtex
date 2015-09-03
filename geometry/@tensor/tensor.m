classdef (InferiorClasses = {?quaternion,?rotation,?orientation}) tensor < dynOption
   
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
        T = M;
        return
      end
      
      T.doubleConvention = check_option(varargin,'doubleConvention');
      
      if isa(M,'vector3d') % conversion from vector3d
        T.M = shiftdim(double(M),ndims(M));
        r = 1;
      
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
        if numel(T.M) == 36,
          T.M = tensor24(T.M,T.doubleConvention);
        elseif numel(T.M) == 18,
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
      else
        T.CS = specimenSymmetry;
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
end
