classdef slipSystem
% class representing slip systems
%
% Syntax
%   sS = slipSystem(b,n)
%   sS = slipSystem(b,n,CRSS)
%
% Input
%  b - @Miller Burgers vector or slip direction
%  n - @Miller slip plane normal
%  CRSS - critical resolved shear stress
%
  
  properties    
    b % slip direction
    n % plane normal 
    CRSS % critical resolved shear stress
  end
  
  properties (Dependent = true)
    CS
  end
  
  methods
    function sS = slipSystem(b,n,CRSS)
      % defines a slipSystem
      %
      % Syntax
      %   sS = slipSystem(b,n)
      %   sS = slipSystem(b,n,CRSS)
      %
      % Input
      %  b - @Miller - Burgers vector or slip direction
      %  n - @Miller - slip plane normal
      %  CRSS - critical resolved shear stress
      %
      
      if nargin == 0, return; end
      
      assert(all(angle(b,n,'noSymmetry') > pi/2-1e-5),...     
        'Slip direction and plane normal should be orthogonal!')
      
      sS.b = b;
      sS.n = n;
      if nargin < 3, CRSS = 1; end
      if numel(CRSS) ~= length(sS.b)
        CRSS = repmat(CRSS,size(sS.b));
      end
      sS.CRSS = CRSS;
      
    end
    
    function CS = get.CS(sS)
      if isa(sS.b,'Miller')
        CS = sS.b.CS;
      else
        CS = specimenSymmetry;
      end
    end
    
    function display(sS,varargin)
      % standard output

      displayClass(sS,inputname(1),varargin{:});
      
      % display symmetry
      if isa(sS.CS,'crystalSymmetry')
        if ~isempty(sS.CS.mineral)
          disp([' mineral: ',char(sS.CS,'verbose')]);
        else
          disp([' symmetry: ',char(sS.CS,'verbose')]);
        end
      end
      
      if length(sS)>24, disp([' CRSS: ' xnum2str(unique(sS.CRSS))]); end
      disp([' size: ' size2str(sS.b)]);
            
      if length(sS)<=45 && ~isempty(sS)
        dispData(sS)
      elseif ~getMTEXpref('generatingHelpMode')
        disp(' ')
        setappdata(0,'dispLastData',@() dispData(sS));
        disp('  <a href="matlab:feval(getappdata(0,''dispLastData''))">display all coordinates</a>')
        disp(' ')
      end
      
      function dispData(sS)
      % display coordinates  
      if isa(sS.CS,'crystalSymmetry')
        if sS.b.lattice.isTriHex
          d = [sS.b.UVTW sS.n.hkil];
          d(abs(d) < 1e-10) = 0;
          cprintf([d,reshape(sS.CRSS,[],1)],'-L','  ','-Lc',{'U' 'V' 'T' 'W' '| H' 'K' 'I' 'L' 'CRSS'});
        else
          d = [sS.b.uvw sS.n.hkl];
          d(abs(d) < 1e-10) = 0;
          cprintf([d,reshape(sS.CRSS,[],1)],'-L','  ','-Lc',{'u' 'v' 'w' '| h' 'k' 'l' 'CRSS'});
        end
      else
        d = round(100*[sS.b.xyz sS.n.xyz])./100;
        d(abs(d) < 1e-10) = 0;
        cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z' ' |   x' 'y' 'z' });
      end
      end
    end
    
    function str = char(sS,varargin)
      
      for i = 1:length(sS)
        str{i} = [char(sS.n(i),varargin{:}),char(sS.b(i),varargin{:})];
        str{i} = strrep(str{i},'$$','');
      end
      if i == 1, str = char(str); end
      
      
    end
    
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
    
  end
  
  methods (Static = true)
    
    % some predefined slip systems
    % see https://damask.mpie.de/Documentation/CrystalLattice
    
    function  sS = primitiveCubic(cs,varargin)   
      sS = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,1,0,cs,'hkl'),varargin{:});
    end
    function sS = fcc(cs,varargin)
      sS = slipSystem(Miller(0,1,-1,cs,'uvw'),Miller(1,1,1,cs,'hkl'),varargin{:});
    end
    
     function sS = bcc(cs,varargin)
      sS = [slipSystem(Miller(1,-1,1,cs,'uvw'),Miller(0,1,1,cs,'hkl'),varargin{:}),...
        slipSystem(Miller(-1,1,1,cs,'uvw'),Miller(2,1,1,cs,'hkl'),varargin{:}),...
        slipSystem(Miller(-1,1,1,cs,'uvw'),Miller(3,2,1,cs,'hkl'),varargin{:})];
     end
    
     function sS = hcp(cs,varargin)
       warning('There are no predefined slip systems for hcp yet. You might have to define those individually.');      
     end
     
    function sS = basal(cs,varargin)
      % <11-20>{0001}
      sS = slipSystem(Miller(1,1,-2,0,cs,'uvtw'),Miller(0,0,0,1,cs,'hkil'),varargin{:});
    end
         
    function sS = prismaticA(cs,varargin)
      %<2-1-1 0>{01-10}
      sS = slipSystem(Miller(2,-1,-1,0,cs,'uvtw'),Miller(0,1,-1,0,cs,'hkil'),varargin{:});
    end
    
    function sS = prismatic2A(cs,varargin)
    %2nd order prismatic compound <a> slip system in hexagonal lattice:
    %<01-10>{2-1-10}
    sS = slipSystem(Miller(0,1,-1,0,cs,'uvtw'),Miller(2,-1,-1,0,cs,'hkil'),varargin{:});
    end
    
    function sS = pyramidalA(cs,varargin)
      % first order pyramidal a slip 
      sS = slipSystem(Miller(2,-1,-1,0,cs,'uvtw'),Miller(0,1,-1,1,cs,'hkil'),varargin{:});
    end
    
    function sS = pyramidalCA(cs,varargin)
      % first order pyramidal <c+a> slip 
      sS = slipSystem(Miller(2,-1,-1,3,cs,'uvtw'),...
        Miller(-1,1,0,1,cs,'hkil'),varargin{:});
    end
    
    function sS = pyramidal2CA(cs,varargin)
      % second order pyramidal <c+a> slip 
      sS = slipSystem(Miller(2,-1,-1,3,cs,'uvtw'),...
        Miller(-2,1,1,2,cs,'hkil'),varargin{:});
    end
    
    function sS = twinT1(cs,varargin)
      % most often tensil twin 
      sS = slipSystem(Miller(1,-1,0,1,cs,'uvtw'),...
        Miller(-1,1,0,2,cs,'hkil'),varargin{:});
    end
    
    function sS = twinT2(cs,varargin)
      % tensil twinning
      sS = slipSystem(Miller(2,-1,-1,6,cs,'uvtw'),...
        Miller(-2,1,1,1,cs,'hkil'),varargin{:});
    end
        
    function sS = twinC1(cs,varargin)
      % compressive twinning
      sS = slipSystem(Miller(-1,1,0,-2,cs,'uvtw'),Miller(-1,1,0,1,cs,'hkil'),varargin{:});
    end
    
    function sS = twinC2(cs,varargin)
      % compressive twinning
      sS = slipSystem(Miller(2,-1,-1,-3,cs,'uvtw'),Miller(2,-1,-1,2,cs,'hkil'),varargin{:});
    end
    
  end
  
end
