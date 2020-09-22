classdef embedding
  % defines an embedding of the orientation space into an Eucledian space
  %
  % Syntax
  %
  %   e = embedding(ori)
  %   e = embedding(u,cs,l)
  %
  % Input
  %  ori - @orientation
  %  u   - cell list of tensors describing the embedding
  %  cs  - @crystalSymmetry
  %  l   - original vectors, i.e., u = ori * l
  %
  % Output
  %  e   - @embedding
  %
  % References
  % 
  % * R .Hielscher, L. Lippert, Isometric Embeddings of Quotients of the
  % Rotation Group Modulo Finite Symmetries,
  % <https://arxiv.org/abs/2007.09664 arXiv:2007.09664>, 2020.
  %
  % See also
  % OrientationEmbeddings
  
  properties
    u  % cell list of tensors describing the embedding
    CS % crystal symmetry
    l  % original vectors
    rank % rank of the tensors
  end
  
  properties (Hidden = true)
    rho % radius of the embedding befor normalization
  end
  
  properties (Dependent = true)
    M
  end
  
  methods
    
    function obj = embedding(u,cs,l)
      % constructor
      
      if isa(u,'orientation')
      
        % embedding is rotated version of the embedding of the identity
        obj = u * embedding.id(u.CS);
        
      else
        
        obj.u = u;
        obj.CS = cs;
        obj.l = l;
        obj.rank = cellfun(@(t) t.rank,obj.u);

      end
      
    end
    
    function d = get.M(e)
      
      d = double(e);
      
    end
    
    function e = set.M(e,d)
      
      e = setDouble(e,d);
      
    end
           
    function obj1 = uminus(obj1)
      
      for i = 1:length(obj1.u)
        obj1.u{i} = -obj1.u{i};
      end
      
    end 
          
    function varargout = subsref(obj,s)
      %overloads subsref

      switch s(1).type
        case '()'
          
          for i = 1:length(obj.u)
            obj.u{i} = subsref(obj.u{i},s(1));
          end
          
          if numel(s)>1
            [varargout{1:nargout}] = builtin('subsref',obj,s(2:end));
          else
            varargout{1} = obj;
          end
        otherwise
          [varargout{1:nargout}] = builtin('subsref',obj,s);
      end
    end
  
    
    function obj = subsasgn(obj,s,b)
      % overloads subsasgn

      if ~isa(obj,'embedding') && ~isempty(b)
        obj = b;
        for i = 1:length(obj.u), obj.u{i}(:) = []; end
        
      end

      switch s(1).type
  
        case '()'
      
          if numel(s)>1, b =  builtin('subsasgn',subsref(obj,s(1)),s(2:end),b); end
          
          if isnumeric(b)
            for i = 1:length(obj.u), obj.u{i} = subsasgn(obj.u{i},s(1),b); end
          else
            for i = 1:length(obj.u), obj.u{i} = subsasgn(obj.u{i},s(1),b.u{i}); end
          end
        otherwise
          obj =  builtin('subsasgn',obj,s,b);          
      end
    end

    
    function obj = rdivide(obj,d)
      % ./
      
      for i = 1:length(obj.u)       
        obj.u{i} = obj.u{i} ./ d;
      end
      
    end
    
    function obj = reshape(obj,varargin)
      for i = 1:length(obj.u), obj.u{i} = reshape(obj.u{i},varargin{:}); end
    end
    
    function obj = transpose(obj)
      for i = 1:length(obj.u), obj.u{i} = obj.u{i}.'; end
    end
    
    function obj = ctranspose(obj)
      for i = 1:length(obj.u), obj.u{i} = obj.u{i}'; end
    end       
    
    function varargout = size(obj,varargin)
      [varargout{1:nargout}] = size(obj.u{1},varargin{:});
    end
    
    function display(obj,varargin)
      % standard output

      displayClass(obj,inputname(1),varargin{:});

      disp([' symmetry: ',char(obj.CS,'verbose')]);
      disp([' ranks: ',xnum2str(obj.rank,'delimiter',', ')]);
      disp([' dim: ' xnum2str(obj.dim)]);
      disp([' size: ' size2str(obj)]);
      
      if prod(size(obj))~=1, return; end %#ok<PSIZE>
      
      for k = 1:length(obj.u)
        display(obj.u{k},'name',['u' num2str(k)])
      end
    end
    
    function d = dim(obj)
      d = size(obj.M,2);
    end
    
    
  end
  
  methods (Static = true)
    
    function obj = id(cs,varargin)
      %
      % Input
      %  cs - @crystalSymmetry
      %
      % Output
      %  obj - @embedding
      %
          
      [l,alpha,weights] = embedding.coefficients(cs);
      
      % embedding of the identical orientation
      u = cell(length(l),1);
      for i = 1:length(l)
        if alpha(i) > 1
            u{i} = mean((cs.properGroup.rot*l(i))^alpha(i)).*weights(i);  
        else
          u{i} =  mean(cs.properGroup.rot*l(i)).*weights(i);
        end
      end
      
      % define the embedding
      obj = embedding(u,cs,l);
      
      
      % subtract mean value - this ensures that 
      %
      % S3G = equispacedSO3Grid(cs)
      % E = mean(embedding(S3G))
      % E.u{1}
      %
      % should be approximately zero            
      obj = obj - embedding.zero(obj,weights);
      
      obj.rho = norm(obj);
      
      % normalize
      obj = obj ./ obj.rho;
      
    end
      
    function obj = rand(varargin)
      %
      % Input
      %  cs - @crystalSymmetry
      %
      % Output
      %  obj - @embedding
      %
          
      cs = getClass(varargin,'symmetry');
      obj = embedding.id(cs);
      
      % get size
      s = varargin(cellfun(@isnumeric,varargin));
      if isempty(s)
        s = {1,1};
      elseif length(s) == 1
        s = [s,1];
      end
      
      % random vector in linear space
      obj.M = rand(prod([s{:}]),obj.dim);
      
      % reshapre correctly
      obj = reshape(obj./norm(obj),[s{:}]);
      
    end
        
    function t = tangential(cs)
      
      id = embedding.id(cs);
      
      % the scew symmetric matrices
      S = spinTensor([xvector;yvector;zvector]);
     
      u = cell(length(id.u),1);
      for i = 1:length(u)
        
        alpha = id.rank(i);
        
        if alpha == 1
          u{i} = S * id.u{i};
        else
          u{i} = tensor.zeros(3,'rank',alpha);
          for j = 1:alpha
            ind = 1:alpha; ind(j) = -1;
            u{i} = u{i} + EinsteinSum(S,[j -1],id.u{i},ind);
          end
        end        
      end
      
      % define the embedding
      t = embedding(u,cs,id.l);
      
      t = t ./ norm(t);
      t.rho = id.rho;
      
      % symmetrise
      %t = t.symmetrise;
      
    end
    
    function [l,alpha,weights] = coefficients(cs)
      % coefficients for isometric embeddings  
      %
      %
      
      % TODO: 
      % * complete this list
      % * make it more compact, e.g. one may use CS.nfold to get the order 
      % of the highest symmetry axis or cs.multiplicityPerpZ 
      % * show that these definitions are indeed symmetry invariant
      % * what is the connection betweem dot(obj1,obj2) and the usual dot
      % on S3 moduluo symmetry
      
      %       l = [vector3d.X, vector3d.Y, vector3d.Z];
      %       alpha = [1,1,1];
      %       weights = [1,1,1];
      
      switch cs.Laue.id
      
        case 2 % -1 --> ok
          l = [vector3d.X, vector3d.Y, vector3d.Z];
     	alpha = [1,1,1];
        weights = [1/sqrt(2),1/sqrt(2),1/sqrt(2)];
        
        case {5,8,11} % C2 ---> ok
          l(1) = unique(cs.elements,'antipodal');
          l(2) = perp(l(1));
          l(3) = cross(l(1),l(2)); 
          
          % alpha = [1,2];
           alpha = [1,2,2];
           weights = [1/sqrt(2),1/2,1/2];

                      
        case 16 % mmm --> ok
          % l = [vector3d.X, vector3d.Y];
          % alpha = [2,2];
            
          l = [vector3d.X, vector3d.Y, vector3d.Z];
          alpha = [2,2,2];
          weights = [1/2,1/2,1/2];
         
        case 18 % C3 --> sometimes 180° off if initial value is (0,0,0)
          
          l = [vector3d(cs.aAxisRec).normalize, vector3d(cs.cAxis).normalize];
          alpha = [3,1];
          weights = [sqrt(8)/(sqrt(2)*3),sqrt(5/6)];
                               
        case 21 % 321 --> ok
          
          l = [vector3d(rotate(cs.aAxisRec,30*degree)).normalize,vector3d(cs.cAxis).normalize];
          alpha = [3,2];
          weights = [sqrt(8)/(sqrt(2)*3),sqrt(5/12)];
          %l = [vector3d(rotate(cs.aAxisRec,30*degree)).normalize];
          %alpha = [3];
          
          
        case 24 % 312 --> ok
            
          %l = [vector3d(cs.aAxisRec).normalize];
          %alpha = [3];
          l = [vector3d(cs.aAxisRec).normalize,vector3d(cs.cAxis).normalize];
          alpha = [3,2];
          weights = [sqrt(8)/(sqrt(2)*3),sqrt(5/12)];

        case 27 % C4 --> ok
          
          l = [vector3d(cs.aAxis).normalize, vector3d(cs.cAxis).normalize];
          alpha = [4,1];
          weights = [1/sqrt(2),1/sqrt(2)];
            
        case 32 % D4 --> ok
          % l = [vector3d(cs.aAxis).normalize];
          %alpha = [4];
          l = [vector3d(cs.aAxis).normalize, vector3d(cs.cAxis).normalize];
          alpha = [4,2];
          weights = [1/sqrt(2),1/2];
          
        case 35 % C6 --> sometimes 180° off if initial value is (0,0,0)
          
          l = [vector3d(cs.aAxis).normalize, vector3d(cs.cAxis).normalize];
          alpha = [6,1];
          weights = [4/(sqrt(2)*3),1/sqrt(12)];
          
        case 40 % D6 --> ok
          % alpha = [6]; 
          %l = [vector3d(cs.aAxis).normalize];
          l = [vector3d(cs.aAxis).normalize, vector3d(cs.cAxis).normalize];
          alpha = [6,2];
          weights = [4/(sqrt(2)*3),1/sqrt(24)];
          
        case 42 % T
          l(1) = vector3d([1/sqrt(3),1/sqrt(3),1/sqrt(3)]);
          alpha(1) = 3;
          weights(1) = 3/(2*sqrt(2));
            
          
        case 45 % 432 % --> ok
          
          l(1) = vector3d(cs.aAxis).normalize;
          alpha(1) = 4;
          weights(1) = 3/(2*sqrt(2));
                    
      end
      
      l = normalize(l);
      
    end
      
      
    function obj = zero(obj,weights)
      
      if nargin < 2, weights = ones(length(obj.u),1); end
      
      for i = 1:length(obj.u)        
        r = obj.rank(i);
        if iseven(r)
          obj.u{i} = weights(i)/(r+1) * sym(dyad(tensor.eye,r/2));
        else
          obj.u{i} = 0 * obj.u{i};
        end
      end
    end
    
    function testMean(cs,n)
      
      if nargin == 0, cs = crystalSymmetry('432'); end
      if nargin < 2, n = 1; end
      ori = orientation.rand(cs);
      odf = unimodalODF(ori,'halfwidth',20*degree);
      sample = odf.discreteSample(n*100);
      
      tic
      for i = 1:n
        localSample = sample((i-1)*100+(1:100));
        T = embedding(localSample);
        Tmean = mean(T);
        mSample = project(Tmean);
              
        mSample2 = mean(localSample);
        h(i) = angle(mSample,mSample2) ./ degree;
        g(i) = mean(angle(localSample,mSample2))-mean(angle(localSample,mSample));
        progress(i,n);
      end
      toc
      
      if n == 1
        h
      else
        figure(1)
        histogram(h);
        figure(2)
        histogram(g./degree);
      end
      
    end
    
    function testMean2(cs)
      
      S3G = equispacedSO3Grid(cs,'points',100000);
      E = mean(embedding(S3G));
      max(max(max(reshape(double(E.u{1}),[],1))))
       
    end

    function testDist(cs,varargin)

      % some random orientations
      odf = unimodalODF(orientation.id(cs)) + uniformODF(cs);
      %sodf = unimodalODF(orientation.id(cs),'halfwidth',0.5*degree);
      ori = odf.discreteSample(100000);
      
      % compute the embedding
      E = embedding(ori);
      id = embedding.id(cs);
           
      % 
      %scatter(angle(ori)./degree,norm(E - id),5,abs(pi/2-angle(ori.axis,zvector))./degree)
      scatter(angle(ori),norm(E - id),5,zeros(100000,1));
      %axis equal tight
      
    end
    
    function testZero(cs)
      n = logspace(0,6);

      for i = 1:length(n)
        e = embedding(orientation.rand(round(n(i)),cs));
        nn(i) = norm(mean(e));
      end
      
      loglog(n,nn,'.')
    end
    
    
    function checkProjection(ori)
      
      
      if nargin == 0
        disp(' ');
        for k = 1:11
          embedding.checkProjection(crystalSymmetry('laueId',k));
        end
        return
      elseif isa(ori,'symmetry')
        ori = orientation.rand(1000,ori);
      end
      cs  = ori.CS;
      
      
      try
        
        t = ori*embedding.tangential(cs);
        r = embedding.rand(size(ori),cs);
      
        n = r - sum(dot(repmat(r,1,3),t) .* t,2);
      
        % check orthogonolity of the normal vector
        % dot(n(1),t(1,:))
      
        e = embedding(ori) + 0.01 * n;
                
        [oriRec, ~, numIter] = project(e);
      
        if max(angle(ori,oriRec)./degree)<1e-5
          disp([cs.LaueName, ' ..... passed, iterations: ' int2str(numIter)]);
        else
          disp([cs.LaueName, ' ..... error: ' ...
            xnum2str(max(angle(ori,oriRec)./degree)) '° ' ...
            'iterations: ' int2str(numIter)]);
        end
      catch
        disp([cs.LaueName, ' ..... error']);
      end
      
    end
    
    function checkDouble(ori)
      
      if nargin == 0
        disp(' ');
        for k = 1:11
          embedding.checkDouble(crystalSymmetry('laueId',k));
        end
        return
      elseif isa(ori,'symmetry')
        ori = orientation.rand(1000,ori);
      end
      cs  = ori.CS;

      try
        
        e = embedding(ori) + 0.01 * embedding.rand(size(ori),cs);
      
        eNew = e;
        eNew.M = e.M;
                  
        if max(norm(e-eNew))<1e-8
          disp([cs.LaueName, ' ..... passed']);
        else
          disp([cs.LaueName, ' ..... not passed']);
        end
      catch
        disp([cs.LaueName, ' ..... error']);
      end
    end
  end
    
end

