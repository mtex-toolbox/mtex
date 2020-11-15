classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

properties
  axes = [xvector,yvector,zvector]; 
  plotOptions = {}
end

  methods
    
    function s = specimenSymmetry(varargin)
      % defines a specimen symmetry
      %
      % usually specimen symmetry is either triclinic or orthorhombic
      %
     
      axes = getClass(varargin,'vector3d',[xvector,yvector,zvector]);
      
      if nargin == 0
        
        id = 1;
        rot = rotation.id;
        
      elseif isa(varargin{1},'quaternion') % define the symmetry just by rotations

        rot = varargin{1};
              
        if check_option(varargin,'pointId')
          id = get_option(varargin,'pointId');
        else
          id = symmetry.rot2pointId(rot,axes);
        end
        
      else
        
        id = symmetry.extractPointId(varargin{:});
        rot = symmetry.calcQuat(id,axes);
        
      end
      
      s = s@symmetry(id,rot);
      s.axes = axes;
             
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' char(s.lattice) ' ' doclink(s) ' ' docmethods(inputname(1))]);
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
