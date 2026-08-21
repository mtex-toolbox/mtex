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
    isSymmetrised
  end
  
  methods
    function sS = slipSystem(b,n,CRSS,cs)
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

      if nargin == 4
        b = Miller(b{:},'uvw',cs);
        n = Miller(n{:},cs);
      end
        
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
        CS = specimenSymmetry.default;
      end
    end
    
    function out = get.isSymmetrised(sS)
      if length(sS)<2
        out = false;
      else
        out = eq(sS.subSet(1),sS.subSet(2));
      end
    end

    function sS = ensureSymmetrised(sS,varargin)
      if ~sS.isSymmetrised, sS = sS.symmetrise(varargin{:}); end
    end

    function display(sS,varargin) %#ok<DISPLAY>
      % standard output

      % a slip system in the crystal frame shows its symmetry, a rotated
      % one - plain vector3d directions - the frame it landed in
      if isa(sS.b,'Miller')
        info = char(sS.CS,'compact');
      else
        info = referenceFrame.headerChar(sS.b.frame,sS.b.how2plot);
      end
      displayClass(sS,inputname(1),varargin{:},'moreInfo',info);
      
      if length(sS)>24, disp([' CRSS: ' xnum2str(unique(sS.CRSS))]); end
      if length(sS)>1, disp([' size: ' size2str(sS.b)]); end
        
      disp(' ');

      if length(sS)<=45 && ~isempty(sS)
        dispData(sS)
      elseif ~getMTEXpref('generatingHelpMode')
        disp(' ')
        s = setAllAppdata(0,'data2beDisplayed',@() dispData(sS));
        disp(['  <a href="matlab:feval(getappdata(0,''',s,'''))">display all coordinates</a>'])
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
        str{i} = [char(sS.n(i),varargin{:}),char(sS.b(i),varargin{:})]; %#ok<AGROW>
        str{i} = strrep(str{i},'$$',''); %#ok<AGROW>
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
    
     function sS = hcp(varargin) %#ok<STOUT>
       % There is no hcp default and there will not be one: which families
       % carry the deformation of a hexagonal material, and at which
       % relative CRSS, is a property of the material and of the experiment
       % rather than of the lattice - so the caller has to say. Every family
       % one would pick from is predefined on its own, so the message lists
       % them instead of leaving the user to find them.

       error('MTEX:slipSystem:hcp','%s',slipSystem.hexHint(...
         ['There is no predefined set of hcp slip systems, and this is on ' ...
          'purpose: which slip and twinning systems carry the deformation of ' ...
          'a hexagonal material depends strongly on the material itself, on ' ...
          'temperature and on the loading - and so do their critical resolved ' ...
          'shear stresses (CRSS). Please combine the families you need ' ...
          'yourself, handing the CRSS of each family in as second argument, ' ...
          'e.g.'],...
         ['  sS = [slipSystem.basal(cs,1), slipSystem.prismatic2A(cs,66), ...' newline ...
          '        slipSystem.pyramidalCA(cs,80), slipSystem.twinC1(cs,100)]']));
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

  methods (Static = true, Hidden = true)

    function msg = hexHint(prose,example)
      % the message behind slipSystem.hcp and dislocationSystem.hcp
      %
      % Both refuse to guess a hexagonal family set and both have to say
      % which families there are instead, so the list lives here once. The
      % prose and the example differ per class and are handed in.
      %
      % Syntax
      %   msg = slipSystem.hexHint(prose,example)
      %
      % Input
      %  prose   - paragraph explaining why there is no default, wrapped here
      %  example - code block, printed as it comes in
      %

      families = {...
        'basal','<11-20>{0001}','';...
        'prismaticA','<2-1-10>{01-10}','';...
        'prismatic2A','<01-10>{2-1-10}','2nd order prismatic';...
        'pyramidalA','<2-1-10>{01-11}','1st order pyramidal <a>';...
        'pyramidalCA','<2-1-13>{-1101}','1st order pyramidal <c+a>';...
        'pyramidal2CA','<2-1-13>{-2112}','2nd order pyramidal <c+a>';...
        'twinT1','<1-101>{-1102}','tensile twinning';...
        'twinT2','<2-1-16>{-2111}','tensile twinning';...
        'twinC1','<-110-2>{-1101}','compressive twinning';...
        'twinC2','<2-1-1-3>{2-1-12}','compressive twinning'};

      % pad behind the call and behind the indices, never inside them - these
      % lines are there to be copied
      call = strcat('  slipSystem.',families(:,1),'(cs)');
      list = cellfun(@(c,m,t) deblank([pad(c) '   ' pad(m) '   ' t]),...
        pad(call),pad(families(:,2)),families(:,3),'UniformOutput',false);

      % a line reaching exactly the window width gets wrapped a second time
      % by the command window itself, which lands mid-indent - leave a column
      cms = get(0,'CommandWindowSize');
      width = max(20,cms(1) - 1);

      msg = [wraptext(prose,width) newline newline ...
        example newline newline ...
        wraptext('The predefined hexagonal families are',width) newline newline ...
        strjoin(list.',newline) newline newline ...
        wraptext(['See ' doclink('SlipSystems','SlipSystems') ' for details.'],width)];

    end

  end

end
