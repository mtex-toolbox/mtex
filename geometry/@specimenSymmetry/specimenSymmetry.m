classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

properties
  plotOptions = {}
end

  methods
    
    function s = specimenSymmetry(varargin)
      % defines a specimen symmetry
      %
      % usually specimen symmetry is either triclinic or orthorhombic
      %
     
      if nargin > 0      
        id = symmetry.extractPointId(varargin{:});
      
        % compute symmetry operations
        rot = getClass(varargin,'quaternion');
        if isempty(rot), rot = symmetry.calcQuat(id,[xvector,yvector,zvector]); end
      else
        id = 1;
        rot = [];        
      end  
             
      s = s@symmetry(id,rot);
             
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' s.lattice ' ' doclink(s) ' ' docmethods(inputname(1))]);
      disp(' ');
    end        
    
  end
  
  methods (Static = true)
    
    function cs = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
       % maybe there is nothing to do
      if isa(s,'specimenSymmetry'), cs = s; return; end
      
      if isfield(s,'rot')
        rot = s.rot;
      else
        rot = rotation(s.a,s.b,s.c,s.d,s.i);
      end
      
      if isfield(s,'axes')
        axes = s.axes;
      else
        axes = [];
      end
      
      if isfield(s,'id')
        id = {'pointId',s.id};
      else
        id = {};
      end
            
      cs = specimenSymmetry(rot,id{:},axes);
      
      if isfield(s,'opt'), cs.opt = s.opt; end
      if isfield(s,'plotOptions'), cs.plotOptions = s.plotOptions; end      
            
    end
    
    
  end
  
  
end
