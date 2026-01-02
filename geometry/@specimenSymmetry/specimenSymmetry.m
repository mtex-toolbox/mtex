classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

methods
    
  function s = specimenSymmetry(varargin)
    % defines a specimen symmetry
    %
    % usually specimen symmetry is either triclinic or orthorhombic
    %
    
    if nargin == 0 || isa(varargin{1},'plottingConvention')
      
      id = 1;
      rot = rotation.id;
      
    else
      
      if isa(varargin{1},'quaternion') % define the symmetry just by rotations
      
        rot = varargin{1};
      
        if check_option(varargin,'pointId')
          id = get_option(varargin,'pointId');
        else
          id = symmetry.rot2pointId(rot,varargin{:});
        end
      
      else
      
        id = symmetry.extractPointId(varargin{:});
        rot = symmetry.calcQuat(id,varargin{:});
      
      end
      
    end
    
    how2plot = getClass(varargin,'plottingConvention');
    if isempty(how2plot), how2plot = plottingConvention.default; end

    s = s@symmetry(id,rot,how2plot);
    
    if s.id > 16
      warning(s.pointGroup + " is not a suitable specimen symmetry!")
    end


  end

  function makeDefault(ss)
    specimenSymmetry.default(ss);
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
    if isa(s,'specimenSymmetry')
      if isempty(s.multiplicityPerpZ)
        isPerpZ = isnull(dot(s.rot.axis,zvector)) & ~isnull(s.rot.angle);
        
        if any(isPerpZ(:))
          s.multiplicityPerpZ = round(2*pi/min(abs(angle(s.rot(isPerpZ)))));
        else
          s.multiplicityPerpZ = 1;
        end
      end
      cs = s;
      return;
    end
      
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
    if isfield(s,'how2plot'), cs.how2plot = s.how2plot; end
            
  end


  function ss = default(ss)
      persistent save
      if nargin == 1
        save =  ss;
      else
        if isempty(save)
          save = specimenSymmetry(plottingConvention); 
        end
        ss = save;
      end
    end
    
end
  

end
