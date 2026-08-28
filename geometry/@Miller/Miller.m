classdef Miller < vector3d
  %
  % The class *Miller* describes crystal directions, i.e., directions
  % relative to the crystal coordinate system. Internally, these are stored
  % with respect to an Euclidean reference system.
  %
  % Syntax
  %   m = Miller(h,k,l,cs)
  %   m = Miller(h,k,i,l,cs)
  %   m = Miller(u,v,w,cs,'uvw')
  %   m = Miller(U,V,T,W,cs,'UVTW')
  %   m = Miller({h1 k1 l1},{h2 k2 l2},{h3 k3 l3},cs) % list of indices
  %   m = Miller('(hkl)',cs)
  %   m = Miller('[uvw]',cs)
  %   m = Miller('[uvw]\[uvw],cs)
  %   m = Miller('(hkl)\(hkl),cs)
  %   m = Miller(x,cs)
  %
  % Input
  %  h,k,l   - three digit reciprocal coordinates
  %  h,k,i,l - four digit reciprocal coordinates
  %  u,v,w   - three digit direct coordinates
  %  U,V,T,W - four digit direct coordinates - Weber indices
  %  x       - @vector3d
  %  cs      - @crystalSymmetry
  %
  % Class Properties
  %  CS        - @crystalSymmetry
  %  dispStyle - 'hkl', 'uvw', 'hkil', 'UVTW'
  %
  % See also
  % CrystalDirections CrystalOperations CrystalReferenceSystem
  % CrystalSymmetries FundamentalSector vector3d.vector3d
  % crystalSymmetry.crystalSymmetry
  
  methods
    
    function m = Miller(varargin)
      % constructor
      
      %empty constructor
      if nargin == 0, return; end
      
           
      % copy constructor
      if isa(varargin{1},'Miller') 
  
        m = varargin{1};
        m.framePrivate = getClass(varargin,'crystalFrame',m.framePrivate);
        m.dispStyle = get_flag(varargin,{'uvw','UVTW','hkl','hkil','xyz'},m.dispStyle);
        
        return;
      end

      % check for symmetry
      m.framePrivate = getClass(varargin,'crystalFrame',[]);
      assert(isa(varargin{1},'Miller') || ~isempty(m.framePrivate),...
        'No crystal symmetry has been specified when defining a crystal direction!');

      % extract disp style
      if m.lattice.isTriHex, m.dispStyle = 'hkil'; end
      m.dispStyle = get_flag(varargin,{'uvw','UVTW','hkl','hkil','xyz'},m.dispStyle);

      if isa(varargin{1},'referenceFrame')

        if nargin > 1
          m.x = varargin{2};
          m.y = varargin{3};
          m.z = varargin{4};
        end
      
      elseif ischar(varargin{1})
        
        m = s2v(varargin{1},m);
              
      elseif isa(varargin{1},'vector3d') % vector3d
  
        [m.x,m.y,m.z] = double(varargin{1});
        m.opt = varargin{1}.opt;
        m.antipodal = varargin{1}.antipodal;
        
      elseif iscell(varargin{1}) && ~isempty(varargin{1}) % list of Miller indices
        
        ind = find(cellfun(@iscell,varargin));
        m = Miller(varargin{ind(1)}{:},varargin{:});
        for i = 2:numel(ind)
          mm = Miller(varargin{ind(i)}{:},varargin{:});
          m =  [m,mm];
        end
        
      elseif isa(varargin{1},'double') && ~isempty(varargin{1}) % hkl and uvw
        
        % get hkls and uvw from input
        nparam = min([length(varargin),4,find(cellfun(@(x) ~isa(x,'double'),varargin),1)-1]);
        
        % check for right input
        if nparam < 3, error('You need at least 3 Miller indice!');end
        
        % check fourth coefficient is right
        if nparam==4 && all(abs(varargin{1} + varargin{2} + varargin{3}) > eps*10)
          if check_option(varargin,{'uvw','uvtw','direction'})
            warning(['Convention u+v+t=0 violated! I assume t = ',num2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          else
            warning(['Convention h+k+i=0 violated! I assume i = ',num2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          end
        end
        
        % set coordinates
        coord = reshape([varargin{1:nparam}],[],nparam);
                
        if check_option(varargin,{'uvw','uvtw','direction'})
          
          if nparam == 3 && ~check_option(varargin,'uvtw')
            m.uvw = coord;
          else
            m.UVTW = coord;
          end
          
        elseif check_option(varargin,'xyz')
          
          m.x = coord(:,1);
          m.y = coord(:,2);
          m.z = coord(:,3);
          m.dispStyle = 'xyz';
          
        else          
          
          m.hkl = coord;
          
        end
        
      end
      
      % add antipodal symmetry ?
      m.antipodal = m.antipodal | check_option(varargin,'antipodal');      

    end        
    
  end
  
  methods (Static = true)

    function m = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions

      if isa(s,'Miller'), m = s; return; end

      % a pre-frame Miller arrives as a struct, its frame comes from the symmetry
      % a pre-merge Miller kept its frame in CSprivate of its own
      if isfield(s,'CSprivate') && isa(s.CSprivate,'crystalFrame')
        fr = s.CSprivate;
      else
        fr = s.framePrivate;
      end
      m = Miller(vector3d(s.x,s.y,s.z),fr);
      if isfield(s,'dispStyle'),    m.dispStyle = s.dispStyle; end
      if isfield(s,'antipodal'),    m.antipodal = s.antipodal; end
      if isfield(s,'isNormalized'), m.isNormalized = s.isNormalized; end
      if isfield(s,'opt'),          m.opt = s.opt; end

    end

    function h = nan(varargin)
      s = varargin(cellfun(@isnumeric,varargin));
      v = vector3d.nan(s{:});
      h = Miller(v,varargin{:});
    end
    
    function h = rand(varargin )
      % vector of random vector3d

      s = varargin(cellfun(@isnumeric,varargin));
      v = vector3d.rand(s{:});
      h = Miller(v,varargin{:});
            
    end        
  end
end

