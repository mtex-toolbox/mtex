classdef dislocationSystem
% class representing dislocation
%
% Syntax
%   dS = dislocationSystem(b,l)
%   dS = dislocationSystem(b,l,u)
%   dS = dislocationSystem(b,l,'nu',nu)
%   dS = dislocationSystem(sS)
%   dS = dislocationSystem(sS,'nu',nu)
%
% Input
%  b   - @Miller Burgers vector
%  l   - @Miller line vector
%  sS  - @slipSystem
%  u   - energy
%
% Options
%  nu  - Poisson ratio (default: 0.3)
%
% Class Properties
%  b  - @Miller Burgers vector
%  l  - @Miller line vector
%  u  - energy
%  CS - @crystalSymmetry
%  isEdge  - is edge dislocation
%  isScrew - is screw dislocation
%
% References
%  J.P. Hirth, J. Lothe, Theory of Dislocations, Wiley, 1982
%  W. Pantleon, Resolving the geometrically necessary dislocation content by
%    conventional electron backscattering diffraction, Scripta Materialia, 2008
%
% See also
% DislocationSystems SlipSystems GND

  properties
    b % burgers vector
    l % line vector
    u % line energy of the dislocation system
  end
  
  properties (Dependent = true)
    CS
    isEdge
    isScrew
  end
  
  methods
    function dS = dislocationSystem(sS,varargin)
            
      if nargin == 0, return; end
      
      if isa(sS,'slipSystem')
        
        % define edge dislocations
        if sS.CS.lattice == 'hexagonal' %#ok<BDSCA>
          dS.b = 1/3 * sS.b; 
        elseif sS.CS.lattice == 'cubic' %#ok<BDSCA>
          dS.b = 1/2 * sS.b;
        else
          dS.b = sS.b;
          warning('I could not determine the correct length of the Burgers vector. Please adjust it manually.')
        end
        dS.l = -cross(sS.n,sS.b);
        
        % define screw dislocations
        if sS.CS.lattice == 'hexagonal' %#ok<BDSCA>
          b = 1/3*unique(sS.b,'antipodal','noSymmetry');
        elseif sS.CS.lattice == 'cubic' %#ok<BDSCA>
          b = 1/2*unique(sS.b,'antipodal','noSymmetry');
        else
          b = unique(sS.b,'antipodal','noSymmetry');
          warning('I could not determine the correct length of the Burgers vector. Please adjust it manually.')
        end

        dS.b = [dS.b(:);b(:)];
        dS.l = [dS.l(:);b(:)];
        opt = varargin;
        
      else
        
        l = varargin{1};
        omega = angle(sS,l,'noSymmetry');
        assert(all(omega > pi/2-1e-5 | omega<1e-5),...
          'line vector and burgers vector should be either orthogonal or identical')
      
        dS.b = sS;
        l.antipodal = true;
        dS.l = l;
        opt = varargin(2:end);
        
      end
      
      % line energy based on Frank's rule (u ~ b^2) and isotropic elasticity
      % (Hirth & Lothe 1982, Pantleon 2008)
      nu = get_option(opt,'nu',0.3);
      nu = get_option(opt,'pr',nu);
      beta = angle(dS.b,dS.l,'noSymmetry');
      % u = b^2 for edge (beta = pi/2) and b^2*(1-nu) for screw (beta = 0)
      dS.u = dS.b.norm.^2 .* (1 - nu .* cos(beta).^2);
      
      if ~isempty(opt) && isnumeric(opt{1})
        if isa(sS,'slipSystem') && isscalar(opt{1})
          nu = opt{1};
          dS.u = dS.b.norm.^2 .* (1 - nu .* cos(beta).^2);
        else
          u = opt{1};
          if numel(u) ~= length(dS.b), u = repmat(u,size(dS.b)); end
          dS.u = u;
        end
      elseif check_option(opt,'energy')
        dS.u = get_option(opt,'energy');
      end
      
    end
    
    function CS = get.CS(sS)
      if isa(sS.b,'Miller')
        CS = sS.b.CS;
      else
        CS = specimenSymmetry.default;
      end
    end
    
    function isEdge = get.isEdge(dS)
      isEdge = angle(dS.b,dS.l,'noSymmetry') > pi/2 - 1e-5;
    end
    
    function isScrew = get.isScrew(dS)
      isScrew = angle(dS.b,dS.l,'noSymmetry') < 1e-5;
    end
    
        
    function display(dS,varargin)
      % standard output
      
      displayClass(dS,inputname(1),varargin{:});

      % display symmetry
      if isa(dS.CS,'crystalSymmetry')
        if ~isempty(dS.CS.mineral)
          disp([' mineral: ',char(dS.CS,'verbose')]);
        else
          disp([' symmetry: ',char(dS.CS,'verbose')]);
        end
      end
      
      toChar = @(x) char(round(x),'spaceSep','noUTF8');
      
      if any(dS.isEdge(:))
        
        disp([' edge dislocations : ',size2str(submatrix(ones(size(dS)),dS.isEdge))]);
        
        if isa(dS.CS,'crystalSymmetry')
          matrix = [arrayfun(toChar,dS.b(dS.isEdge),'UniformOutput',false),...
            arrayfun(toChar,dS.l(dS.isEdge),'UniformOutput',false),...
            vec2cell(dS.u(dS.isEdge)), vec2cell(round(norm(dS.b(dS.isEdge)),2))];
        
          cprintf(matrix,'-L',' ','-Lc',...
            {'Burgers vector' 'line vector' 'energy' 'length'},'-d','  ','-ic',true);
          disp(' ');
          
        end
       
      end
      
      if any(dS.isScrew(:))

        
        disp([' screw dislocations: ',size2str(submatrix(ones(size(dS)),dS.isScrew))]);
        
        if isa(dS.CS,'crystalSymmetry')
          matrix = [arrayfun(toChar,dS.b(dS.isScrew),'UniformOutput',false),...
            vec2cell(dS.u(dS.isScrew)), vec2cell(round(norm(dS.b(dS.isScrew)),2))];
        

          cprintf(matrix,'-L',' ','-Lc',...
            {'Burgers vector' 'energy' 'length'},'-d','  ','-ic',true);
          disp(' ');




        end
      end

    end
    
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
    
  end
  
  methods (Static = true)
    function dS = fcc(cs,varargin)
      dS = dislocationSystem(symmetrise(slipSystem.fcc(cs),'antipodal'),varargin{:});
    end
    
    function dS = bcc(cs,varargin)
      dS = dislocationSystem(symmetrise(slipSystem.bcc(cs),'antipodal'),varargin{:});
    end
    
    function dS = hcp(varargin) %#ok<STOUT>
      % There is no hcp counterpart to fcc and bcc, deliberately - see
      % slipSystem.hcp. Calling that one would raise its message, but it
      % talks about slip systems and CRSS, so say the same thing about
      % dislocation systems here rather than sending the user one class on.

      error('MTEX:dislocationSystem:hcp','%s',slipSystem.hexHint(...
        ['There is no predefined set of hcp dislocation systems, and this ' ...
         'is on purpose: which slip and twinning systems carry the ' ...
         'deformation of a hexagonal material depends strongly on the ' ...
         'material itself, on temperature and on the loading. Please build ' ...
         'the dislocation systems from the families you need, e.g.'],...
        ['  dS = dislocationSystem(symmetrise([slipSystem.basal(cs), ...' newline ...
         '        slipSystem.prismatic2A(cs), slipSystem.pyramidalCA(cs)],''antipodal''))']));
    end
     
  end
  
end
