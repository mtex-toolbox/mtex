classdef slipSystem
  % class representing slip systems
  
  properties    
    b % slip direction or burgers vector
    n % plane normal 
  end
  
  properties (Dependent = true)
    CS
  end
  
  methods
    function sS = slipSystem(b,n)
      %
      % Syntax
      %   sS = slipSystem(b,n)
      %
      % Input
      %  b - @Miller - Burgers vector or slip direction
      %  n - @Miller - slip plane normal 
      %
      
      assert(all(angle(b,n,'noSymmetry') > pi/2-1e-5),...     
        'Slip direction and plane normal should be orthogonal!')
      
      sS.b = b;
      n.antipodal = true;
      sS.n = n;
      
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

      disp(' ');
      disp([inputname(1) ' = ' doclink('slipSystem_index','slipSystem') ...
        ' ' docmethods(inputname(1))]);

      disp([' size: ' size2str(sS.b)]);

      % display symmetry
      if isa(sS.CS,'crystalSymmetry')
        if ~isempty(sS.CS.mineral)
          disp([' mineral: ',char(sS.CS,'verbose')]);
        else
          disp([' symmetry: ',char(sS.CS,'verbose')]);
        end
      end
            
      if length(sS)>50, return; end
      
      % display coordinates  
      if isa(sS.CS,'crystalSymmetry')
        if any(strcmp(sS.b.CS.lattice,{'hexagonal','trogonal'}))
          d = [sS.b.UVTW sS.n.hkl];
          d(abs(d) < 1e-10) = 0;
          cprintf(d,'-L','  ','-Lc',{'U' 'V' 'T' 'W' '| H' 'K' 'I' 'L'});
        else
          d = [sS.b.uvw sS.n.hkl];
          d(abs(d) < 1e-10) = 0;
          cprintf(d,'-L','  ','-Lc',{'u' 'v' 'w' '| h' 'k' 'l'});
        end
      else
        d = round(100*[sS.b.xyz sS.n.xyz])./100;
        d(abs(d) < 1e-10) = 0;
        cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z' ' |   x' 'y' 'z'});
      end
    end
    
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
    
  end
  
  methods (Static = true)
    
    function sS = fcc(cs)
      sS = slipSystem(Miller(0,1,-1,cs,'uvw'),Miller(1,1,1,cs,'hkl'));
    end
    
     function sS = bcc(cs)
      sS = [slipSystem(Miller(1,-1,1,cs,'uvw'),Miller(0,1,1,cs,'hkl')),...
        slipSystem(Miller(-1,1,1,cs,'uvw'),Miller(2,1,1,cs,'hkl'))];
     end
    
     function sS = hcp(cs)
       warning('Maybe I should collect here all slipSystems below');
       
     end
     
    function sS = basal(cs)
      % <11-20>{0001}
      sS = slipSystem(Miller(2,-1,-1,0,cs,'UVTW'),Miller(0,1,-1,0,cs,'HKIL'));
    end
         
    function sS = prismaticA(cs)
      %⟨2-1-1 0⟩{01-10}
      sS = slipSystem(Miller(2,-1,-1,0,cs,'uvtw'),Miller(0,1,-1,0,cs,'hkil'));
    end
    
    function sS = prismatic2A(cs)
    %2nd order prismatic compound <a> slip system in hexagonal lattice:
    %⟨01-10⟩{2-1-10}
    sS = slipSystem(Miller(0,1,-1,0,cs,'uvtw'),Miller(2,-1,-1,0,cs,'hkl'));
    end
    
    function sS = pyramidalA(cs)
      % first order pyramidal a slip 
      sS = slipSystem(Miller(2,-1,-1,0,cs,'uvtw'),Miller(0,1,-1,1,cs,'hkl'));
    end
    
    function sS = pyramidalCA(cs)
      % first order pyramidal <c+a> slip 
      sS = slipSystem(Miller(2,-1,-1,3,cs,'uvtw'),Miller(-1,1,0,1,cs,'hkl'));
    end
    
    function sS = pyramidal2CA(cs)
      % second order pyramidal <c+a> slip 
      sS = slipSystem(Miller(2,-1,-1,3,cs,'uvtw'),Miller(-2,1,1,1,cs,'hkl'));
    end
        
  end
  
end