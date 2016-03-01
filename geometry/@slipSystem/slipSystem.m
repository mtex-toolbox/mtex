classdef slipSystem 
  
  properties    
    b % slip direction or burgers vector
    n % plane normal 
  end
  
  properties (Dependent = true)
    CS
  end
  
  methods
    function sS = slipSystem(b,n)
      
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
            
      if numel(sS)>50, return; end
      
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
      sS = slipSystem(Miller(0,1,-1,cs,'uvw'),Miller(0,0,1,cs,'hkl'));
    end
    
     function sS = bcc(cs)
      sS = slipSystem(Miller(1,-1,1,cs,'uvw'),Miller(0,1,1,cs,'hkl'));
    end
    
    function sS = basal(cs)
      % <11-20>{0001}
      sS = slipSystem(Miller(2,-1,-1,0,cs,'UVTW'),Miller(0,1,-1,0,cs,'HKIL'));
    end
         
    function sS = prismatic(cs)
      %⟨112¯0⟩{101¯0}
      sS = slipSystem(Miller(1,1,-2,0,cs,'uvtw'),Miller(1,0,-1,0,cs,'hkl'));
    end
    
    function sS = prismatic2a(cs)
    %2nd order prismatic compound <a> slip system in hexagonal lattice:
    %⟨1¯100⟩{112¯0}
    sS = slipSystem(Miller(1,1,-2,0,cs,'uvtw'),Miller(1,0,-1,0,cs,'hkl'));
    end
    
    
  end
  
end