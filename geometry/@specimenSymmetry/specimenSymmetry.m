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

    s = s@symmetry(id,rot);

    % reuse the registered session frame when the requested convention is
    % exactly the one it carries - handle identity, so that mutating the
    % default in place (plotx2east) keeps reaching this symmetry; fork an
    % unregistered frame otherwise - never write a caller's convention
    % through the shared session frame
    s.frame = specimenSymmetry.frameFor(how2plot);

    if s.id > 16
      warning(s.pointGroup + " is not a suitable specimen symmetry!")
    end


  end

  function makeDefault(ss)
    specimenSymmetry.default(ss);
  end

  function display(s)
    % the plotting convention is shown the same way as for the data
    % classes that carry one - see e.g. @EBSD/display - since for a
    % specimen symmetry it is the only thing besides the point group
    % that distinguishes one instance from another
    disp(' ');
    disp([inputname(1) ' = ' char(s.lattice) ' ' doclink(s) ...
      ' (' char(s.how2plot,'compact') ') ' docmethods(inputname(1))]);
    disp(' ');
  end

  function out = eqTol(obj1,obj2)
    % returns true if both have same symmetry elements and the same lattice

    out = obj1 == obj2 || ...
      (isa(obj1,'specimenSymmetry') && ...
      isa(obj2,'specimenSymmetry') && obj1.Laue.id == obj2.Laue.id);

    end

    function out = sim(obj1,obj2)
      % symmetries are similar if they have same symmetry elements and
      % lattice. It does not require does the axes alignments coincide
      
      out = obj1 == obj2 || ...
        (isa(obj1,'specimenSymmetry') && ...
        isa(obj2,'specimenSymmetry') && obj1.Laue.id == obj2.Laue.id);

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

      % a pre-frame object restored how2plot into the override slot; a
      % modern object arrives with its own deserialized frame. Either way
      % re-intern against the register: attach the session frame when the
      % convention agrees with it (matchDefault re-aliases an
      % equal-by-value one first), fork otherwise - never write a loaded
      % convention through the shared session frame.
      if isempty(s.frame)
        pC = s.how2plotPrivate;
        s.how2plotPrivate = [];
        if isempty(pC), pC = plottingConvention.default; end
        s.frame = specimenSymmetry.frameFor(matchDefault(pC));
      elseif isempty(s.frame.how2plot)
        % the deserialized frame is this object's own handle - safe
        s.frame.how2plot = plottingConvention.default;
      else
        s.frame = referenceFrame.reintern(s.frame);
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
    if isfield(s,'how2plot') && isa(s.how2plot,'plottingConvention')
      % reuse-or-fork - the frame the constructor attached may be the
      % shared session frame, so never write the loaded convention there
      cs.frame = specimenSymmetry.frameFor(matchDefault(s.how2plot));
    end
            
  end


  function fr = frameFor(pC)
    % the registered session frame when pC is exactly the convention it
    % carries (handle identity), an unregistered fork otherwise
    fr = specimenFrame.default;
    if pC ~= fr.how2plot
      fr = specimenFrame('measurement');
      fr.how2plot = pC;
    end
  end

  function ss = default(ss)
      persistent save
      if nargin == 1
        % make ss the default: it adopts the registered default frame,
        % which in turn adopts ss's convention - so the default stays one
        % named entity (specimenFrame.default) whatever the point group
        fr = specimenFrame.default;
        pC = ss.how2plot;
        if ~isempty(pC) && pC ~= fr.how2plot, fr.how2plot = pC; end
        ss.frame = fr;
        ss.how2plotPrivate = [];
        save = ss;
      else
        if isempty(save)
          % the constructor attaches the registered default frame, which
          % specimenFrame.default seeds with plottingConvention.ij
          save = specimenSymmetry;
        end
        ss = save;
      end
    end
    
end
  

end
