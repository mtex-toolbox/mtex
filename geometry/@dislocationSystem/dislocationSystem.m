classdef dislocationSystem
% class representing dislocation systems
%
% Syntax
%   dS = dislocationSystem(b,l)
%   dS = slipSystem(sS)
%
% Input
%  b - @Miller Burgers vector
%  n - @Miller line vector
%  sS - @slipSystem
%  pr - poissson ratio
%
  
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
    function dS = dislocationSystem(sS,l,u)
            
      if nargin == 0, return; end
    
      % adjust length burger vector edge dislocation a/2
      % for screw dislocations ??
      
      if isa(sS,'slipSystem')
        
        % define edge dislocations
        dS.b = 0.5 * sS.b;
        dS.l = round(cross(sS.b,sS.n));
        
        % define screw dislocations
        b = unique(sS.b,'antipodal','noSymmetry');
        dS.b = [dS.b;b];
        dS.l = [dS.l;b];
        
        % line energy
        dS.u = 1 + dS.isEdge;
        
      else
        
        b = sS;
        omega = angle(b,l,'noSymmetry');
        assert(all(omega > pi/2-1e-5 || omega<1e-5),...
          'line vector and burgers vector should be either be orthogonal! or identical')
      
        dS.b = sS;
        l.antipodal = true;
        dS.l = l;
        if nargin < 3, u = 1; end
        if numel(u) ~= length(dS.b), u = repmat(u,size(dS.b)); end
        dS.u = u;
        
      end
      
    end
    
    function CS = get.CS(sS)
      if isa(sS.b,'Miller')
        CS = sS.b.CS;
      else
        CS = specimenSymmetry;
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

      disp(' ');
      disp([inputname(1) ' = ' doclink('dislocationSystem_index','dislocationSystem') ...
        ' ' docmethods(inputname(1))]);      

      % display symmetry
      if isa(dS.CS,'crystalSymmetry')
        if ~isempty(dS.CS.mineral)
          disp([' mineral: ',char(dS.CS,'verbose')]);
        else
          disp([' symmetry: ',char(dS.CS,'verbose')]);
        end
      end
      
      toChar = @(x) char(round(x),'spaceSep');
      
      if any(dS.isEdge(:))
        
        disp([' edge dislocations : ',size2str(submatrix(ones(size(dS)),dS.isEdge))]);
        
        if isa(dS.CS,'crystalSymmetry')
          matrix = [arrayfun(toChar,dS.b(dS.isEdge),'UniformOutput',false),...
            arrayfun(toChar,dS.l(dS.isEdge),'UniformOutput',false),...
            vec2cell(dS.u(dS.isEdge))];
        
          cprintf(matrix,'-L',' ','-Lc',...
            {'Burgers vector' 'line vector' 'energy'},'-d','  ','-ic',true);
          disp(' ');
          
        end
       
      end
      
      if any(dS.isScrew(:))

        
        disp([' screw dislocations: ',size2str(submatrix(ones(size(dS)),dS.isScrew))]);
        
        if isa(dS.CS,'crystalSymmetry')
          matrix = [arrayfun(toChar,dS.l(dS.isScrew),'UniformOutput',false),...
            vec2cell(dS.u(dS.isScrew))];
        
          cprintf(matrix,'-L',' ','-Lc',...
            {'Burgers vector' 'energy'},'-d','  ','-ic',true);
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
      dS = dislocationSystem(symmetrise(slipSystem.fcc(cs),'antipodal'));
    end
    
    function dS = bcc(cs,varargin)
      dS = dislocationSystem(symmetrise(slipSystem.bcc(cs),'antipodal'));
    end
    
    function dS = hcp(cs,varargin)
      dS = dislocationSystem(symmetrise(slipSystem.hcp(cs),'antipodal'));
    end
     
  end
  
end