classdef Miller < vector3d
% define a crystal direction by Miller indice
%
% Syntax
%   m = Miller(h,k,l,cs) 
%   m = Miller(h,k,l,cs,'hkl') 
%   m = Miller(h,k,l,cs,'pole') 
%   m = Miller(h,k,i,l,cs) 
%   m = Miller('(hkl)',cs) 
%   m = Miller(u,v,w,cs,'uvw') 
%   m = Miller(u,v,t,w,cs,'uvw') 
%   m = Miller(u,v,w,cs,'direction') 
%   m = Miller('[uvw]',cs) 
%   m = Miller('[uvw]\[uvw],cs) 
%   m = Miller('(hkl)\(hkl),cs) 
%   m = Miller(x,cs) % transform vector3d to Miller
%
% Input
%  h,k,l,i(optional) - Miller indice of the plane normal
%  uw,v,w,t(optional) - Miller indice of a direction
%  x  - @vector3d
%  cs - crystal @symmetry
%
% See also
% vector3d_index symmetry_index
  
  properties
    dispStyle = 'hkl' % output convention hkl or uvw
  end
  
  properties (Access = private)
    CSprivate = crystalSymmetry % crystal symmetry
  end
  
  properties (Dependent = true)
    CS        % crystal symmetry
    hkl       % direct coordinates
    h
    k
    i
    l
    uvw       % reciprocal coordinates
    UVTW      % reciprocal coordinates
    u
    v
    w
    U
    V
    T
    W
  end
  
  methods
    
    function m = Miller(varargin)
      % define a crystal direction by Miller indice
      %
      % Syntax
      % m = Miller(h,k,l,cs) -
      % m = Miller(h,k,l,cs,'hkl') -
      % m = Miller(h,k,l,cs,'pole') -
      % m = Miller(h,k,i,l,cs) -
      % m = Miller('(hkl)',cs) -
      % m = Miller(u,v,w,cs,'uvw') -
      % m = Miller(u,v,t,w,cs,'uvw') -
      % m = Miller(u,v,w,cs,'direction') -
      % m = Miller('[uvw]',cs) -
      % m = Miller('[uvw]\[uvw],cs) -
      % m = Miller('(hkl)\(hkl),cs) -
      % m = Miller(x,cs) -
      %
      %
      % Input
      %  h,k,l,i(optional) - Miller indice of the plane normal
      %  u,v,w,t(optional) - Miller indice of a direction
      %  x  - @vector3d
      %  cs - crystal @symmetry
      %
      % See also
      % vector3d_index symmetry_index
      
      if nargin == 0, return; end
      
      % check for symmetry
      m.CSprivate = getClass(varargin,'crystalSymmetry',[]);
      assert(isa(varargin{1},'Miller') || ~isempty(m.CSprivate),...
        ['Starting with MTEX 4.0 Miller ' ...
        'indices always require to specify a crystal symmetry!']);

      if nargin == 0 %empty constructor

        return
  
      elseif isa(varargin{1},'Miller') % copy constructor
  
        if ~isempty(m.CSprivate), varargin{1}.CSprivate = m.CSprivate;end
        m = varargin{1};
        dispStyle = extract_option(varargin,{'uvw','UVTW','hkl','hkil','xyz'}); %#ok<*PROP>
        if ~isempty(dispStyle), m.dispStyle = dispStyle{1}; end
        
        return;
  
      elseif ischar(varargin{1})
        
        m = s2v(varargin{1},m);
              
      elseif isa(varargin{1},'vector3d') % vector3d
  
        [m.x,m.y,m.z] = double(varargin{1});
        m.opt = varargin{1}.opt;
        m.antipodal = varargin{1}.antipodal;
        
      elseif iscell(varargin{1}) % list of Miller indices
        
        ind = find(cellfun(@iscell,varargin));
        m = Miller(varargin{ind(1)}{:},varargin{:});
        for i = 2:numel(ind)
          mm = Miller(varargin{ind(i)}{:},varargin{:});
          m =  [m,mm];
        end
        
        % hkl and uvw
      elseif isa(varargin{1},'double')
        
        % get hkls and uvw from input
        nparam = min([length(varargin),4,find(cellfun(@(x) ~isa(x,'double'),varargin),1)-1]);
        
        % check for right input
        if nparam < 3, error('You need at least 3 Miller indice!');end
        
        % check fourth coefficient is right
        if nparam==4 && all(varargin{1} + varargin{2} + varargin{3} ~= 0)
          if check_option(varargin,{'uvw','uvtw','direction'})
            warning(['Convention u+v+t=0 violated! I assume t = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          else
            warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          end
        end
        
        % set coordinates
        coord = reshape([varargin{1:nparam}],[],nparam);
                
        if check_option(varargin,{'uvw','uvtw','direction'});          
          
          if nparam == 3 && ~check_option(varargin,'uvtw')
            m.uvw = coord;
          else
            m.UVTW = coord;
          end
          
        elseif check_option(varargin,'xyz');
          
          m.x = coord(:,1);
          m.y = coord(:,2);
          m.z = coord(:,3);
          m.dispStyle = 'xyz';
          
        else          
          
          m.hkl = coord;
          
        end
        
      end

      % add antipodal symmetry ?
      m.antipodal = check_option(varargin,'antipodal');

    end
    
    
    function v = vector3d(m)
      v = vector3d(m.x,m.y,m.z);
      v.antipodal = m.antipodal;
      v.opt = m.opt;
    end
    
    % -----------------------------------------------------------
    
    function cs = get.CS(m)
      cs = m.CSprivate;
    end
    
    function m = set.CS(m,cs)             
      % recompute representation in cartesian coordinates
      if m.CSprivate ~= cs

        switch m.dispStyle
    
          case 'uvw'
      
            uvw = m.uvw; %#ok<*PROPLC>
            m.CSprivate = cs;
            m.uvw = uvw;
      
          case 'hkl'
      
            hkl = m.hkl;
            m.CSprivate = cs;
            m.hkl = hkl;
      
          otherwise        
            m.CSprivate = cs;
        end        
      else
        m.CSprivate = cs;
      end      
    end
    
    function hkl = get.hkl(m)
      
      % get reciprocal axes
      M = squeeze(double(m.CS.axesDual)).';
      
      % get xyz coordinates
      v = reshape(double(m),[],3).';

      % compute reciprocal coordinates
      hkl = (M \ v)';

      % add fourth component for trigonal and hexagonal systems
      if any(strcmp(m.CS.lattice,{'trigonal','hexagonal'}))
        hkl = [hkl(:,1:2),-hkl(:,1)-hkl(:,2),hkl(:,3)];
      end
      
    end

    function h = get.h(m), h = m.hkl(:,1);end
    function k = get.k(m), k = m.hkl(:,2);end
    function i = get.i(m), i = m.hkl(:,3);end
    function l = get.l(m), l = m.hkl(:,end);end
        
    % ------------------------------------------------------------
    function m = set.hkl(m,hkl)
      % 
      % hkl must have the format [h,k,l] or [h k i l]
      
      % remove i 
      hkl = hkl(:,[1:2,end]);
      
      % get reciprocal axes
      M = squeeze(double(m.CS.axesDual));
      
      % compute x, y, z coordinates
      m.x = hkl * M(:,1);
      m.y = hkl * M(:,2);
      m.z = hkl * M(:,3); 
      
      % set default display style
      m.dispStyle = 'hkl';
      
    end
    
    function m = set.h(m,h)
      m.hkl = [h m.k m.l];
    end
    
    function m = set.k(m,k)
      m.hkl = [m.h k m.l];
    end
    
    function m = set.l(m,l)
      m.hkl = [m.h m.k l];
    end
    
    function m = set.u(m,u)
      m.uvw = [u m.v m.w];
    end
    
    function m = set.v(m,v)
      m.uvw = [m.u v m.w];
    end
    
    function m = set.w(m,w)
      m.uvw = [m.u m.v w];
    end
    
    function m = set.U(m,U)
      m.UVTW = [U m.V m.T m.T];
    end
    
    function m = set.V(m,V)
      m.UVTW = [m.U V m.T m.W];
    end
    
    function m = set.T(m,T)
      m.UVTW = [m.U m.V T m.W];
    end
    
    function m = set.W(m,W)
      m.UVTW = [m.U m.V m.T W];
    end
        
    % -----------------------------------------------------------            
    function uvw = get.uvw(m)
    
      % get crystal coordinate system (a,b,c)
      M = squeeze(double(m.CS.axes)).';

      % get x, y, z coordinates
      xyz = reshape(double(m),[],3).';

      % compute u, v, w coordinates
      uvw = (M \ xyz)';
     
    end
      
    function UVTW = get.UVTW(m)
      %U = 2u -v, V = 2v - u, T = - (u+v), W = 3w

      uvw = m.uvw;
      
      UVTW = [2*uvw(:,1)-uvw(:,2),...
        2*uvw(:,2)-uvw(:,1),...
        -uvw(:,1)-uvw(:,2),...
        3*uvw(:,3)];
            
    end
    
    
    function u = get.u(m), u = m.uvw(:,1);end
    function v = get.v(m), v = m.uvw(:,2);end
    function w = get.w(m), w = m.uvw(:,3);end
    function U = get.U(m), U = m.UVTW(:,1);end
    function V = get.V(m), V = m.UVTW(:,2);end
    function T = get.T(m), T = m.UVTW(:,3);end
    function W = get.W(m), W = m.UVTW(:,4);end
    
    
        
    % ------------------------------------------------------------
    
    function m = set.uvw(m,uvw)
      %
      % uvw must be of format [u v w] or [u v t w] 
      
      % correct for 4 component vectors
      if size(uvw,2) == 4, error('Use UVTW to set four Miller indice!'); end
               
      % get direct axes 
      M = squeeze(double(m.CS.axes));
      
      % compute x, y, z coordinates
      m.x = uvw * M(:,1);
      m.y = uvw * M(:,2);
      m.z = uvw * M(:,3);
      
      % set default display style
      m.dispStyle = 'uvw';
      
    end
    
    function m = set.UVTW(m,UVTW)
      %    
      %U = 2u -v, V = 2v - u, T = - (u+v), W = 3w
      
      % correct for 4 component vectors
      if size(UVTW,2) == 4
        
        m.uvw = [UVTW(:,1)-UVTW(:,3),UVTW(:,2)-UVTW(:,3),UVTW(:,4)]./3;
        
      elseif any(strcmp(m.CS.lattice,{'trigonal','hexagonal'})) 
        
        m.uvw = [2*UVTW(:,1) + UVTW(:,2),2*UVTW(:,2) + UVTW(:,1),UVTW(:,3)]./3;
        
      end
      
      % set default display style
      m.dispStyle = 'UVTW';
      
    end        
end
  
  methods (Static = true)
    
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

