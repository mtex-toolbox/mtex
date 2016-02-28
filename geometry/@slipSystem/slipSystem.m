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
      sS.n = n;
      
    end
    
    function CS = get.CS(sS)
      if isa(sS.b,'Miller')
        CS = sS.b.CS;
      else
        CS = specimenSymmetry;
      end
    end
    
    function sS = symmetrise(sS)
      % find all symmetrically equivalent slips systems
        
      % find all symmetrically equivalent
      [m,~] = symmetrise(sS.b,'antipodal');
      [n,~] = symmetrise(sS.n,'antipodal'); %#ok<*PROP>
  
      % find orthogonal ones
      [r,c] = find(isnull(dot_outer(vector3d(m),vector3d(n))));

      % restricht to the orthogonal ones
      sS.b = m(r);
      sS.n = n(c);
    end
    
    function display(sS,varargin)
      % standard output

      disp(' ');
      disp([inputname(1) ' = ' doclink('slipSystem_index','slipSystem') ...
        ' ' docmethods(inputname(1))]);

      disp([' size: ' size2str(sS.b)]);

      if ~isa(sS.b,'Miller'), return; end
      
      % display coordinates  
      if any(strcmp(sS.b.CS.lattice,{'hexagonal','trogonal'}))
        d = [sS.b.UVTW sS.n.hkl];
        d(abs(d) < 1e-10) = 0;
        cprintf(d,'-L','  ','-Lc',{'U' 'V' 'T' 'W' '| H' 'K' 'I' 'L'});
      else        
        d = [sS.b.uvw sS.n.hkl];
        d(abs(d) < 1e-10) = 0;
        cprintf(d,'-L','  ','-Lc',{'u' 'v' 'w' '| h' 'k' 'l'});
      end
    end
    
    function value = mPrime(sS1,sS2)
      %
      
      value = abs(dot(sS1.b.normalize,sS2.b.normalize,'noSymmetry') .* ...
        dot(sS1.n.normalize,sS2.n.normalize,'noSymmetry'));
    end

    
    function SF = SchmidFactor(sS,sigma)
      % compute the Schmid factor
      
      b = sS.b.normalize; %#ok<*PROPLC>
      n = sS.n.normalize;
      
      if isa(sigma,'vector3d')
        
        r = sigma.normalize;
        SF = dot_outer(r,b,'noSymmetry') .* dot_outer(r,n,'noSymmetry');
        
      else
   
        SF = zeros(length(sigma),length(b));
        for i = 1:length(sS.b)
          SF(:,i) = double(EinsteinSum(sigma,[-1,-2],n(i),-1,b(i),-2));
        end
        
      end
    end
    
    function sS = rotate(sS,ori)
      % rotate slip system
      
      sS.b = rotate(sS.b,ori);
      sS.n = rotate(sS.n,ori);
      
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