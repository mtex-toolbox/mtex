classdef specimenSymmetry < symmetry
% defines a specimen symmetry
%
% Usually specimen symmetry is either triclinic or orthorhombic - the
% latter for a rolled sheet, where the sample is symmetric with respect to
% the rolling and the transverse direction. Unlike a @crystalSymmetry it
% carries no lattice, only the group and the specimen @referenceFrame.
%
% Passing a reference frame gives the trivial group carrying that frame,
% which is how a plotting convention or a @gridLayout enters an
% @orientation, see ADR 0003.
%
% Syntax
%   ss = specimenSymmetry
%   ss = specimenSymmetry('mmm')
%   ss = specimenSymmetry('orthorhombic')
%   ss = specimenSymmetry(pC)
%   ss = specimenSymmetry(frame)
%
% Input
%  name  - Schoenflies or International notation of the point group
%  pC    - @plottingConvention
%  frame - @referenceFrame to be carried by the trivial group
%
% Output
%  ss - @specimenSymmetry
%
% Class Properties
%  id         - point group id
%  pointGroup - international notation of the point group
%  lattice    - lattice type
%  rot        - the symmetry elements as @rotation
%  frame      - the specimen @referenceFrame
%  how2plot   - @plottingConvention, read only
%
% Example
%
%   ss = specimenSymmetry('mmm')
%
% See also
% symmetry crystalSymmetry specimenFrame
%

methods
    
  function s = specimenSymmetry(varargin)
    % defines a specimen symmetry
    %
    % usually specimen symmetry is either triclinic or orthorhombic
    %
    
    % the trivial group carrying a given frame, see ADR 0003. Any frame
    % that is not a crystalFrame may be carried: a crystal frame holds a
    % lattice this group knows nothing about, while a specimen frame or a
    % grid layout is just an identity plus a basis. That is what lets an
    % orientation name a @gridLayout on one side - see
    % orientation/byScreenAlignment
    frameAdopted = nargin > 0 && isa(varargin{1},'referenceFrame') && ...
      ~isa(varargin{1},'crystalFrame');

    if frameAdopted || nargin == 0 || isa(varargin{1},'plottingConvention')

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
    if frameAdopted && ~isempty(how2plot)
      error('MTEX:specimenSymmetry:frameAndConvention',...
        ['A reference frame carries its own plotting convention - pass '...
        'either a frame or a convention, not both.'])
    end
    if isempty(how2plot), how2plot = plottingConvention.default; end

    s = s@symmetry(id,rot);

    if frameAdopted
      s.frame = varargin{1};
    else
      % reuse the registered session frame when it carries the requested convention
      s.frame = specimenSymmetry.frameFor(how2plot);
    end

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
    %
    % It goes through conventionChar, so a named frame states it in its
    % own axes names ('TD↑→RD') exactly as the data in that frame does -
    % see @vector3d/display

    c = '';
    if ~isempty(s.frame), c = [' (' conventionChar(s.frame) ')']; end

    disp(' ');
    disp([inputname(1) ' = ' char(s.lattice) ' ' doclink(s) c]);
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

      % re-intern against the register, the loaded convention applies to the session
      if isempty(s.frame)
        s.frame = specimenFrame.default;
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
      cs.frame = specimenSymmetry.frameFor(s.how2plot);
    end
            
  end


  function fr = frameFor(pC)
    % the registered session frame when pC equals the convention it
    % carries, an unregistered fork otherwise - the fork keeps the name
    % and the axes names of the session frame
    %
    % Accepts a string like 'y↑→x', and reports no frame for no
    % convention, so that every set.how2plot can be one line through here
    % instead of repeating the normalisation
    if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
    if isempty(pC), fr = []; return; end

    fr = specimenFrame.default;
    if pC ~= fr.how2plot
      fr = copy(fr);
      fr.how2plot = pC;
    end
  end

  function ss = default(ss)
      persistent save
      if nargin == 1
        % make ss the default, which stays specimenFrame.default whatever the group
        fr = specimenFrame.default;
        pC = ss.how2plot;
        if ~isempty(pC) && pC ~= fr.how2plot, fr.how2plot = pC; end
        ss.frame = fr;
        save = ss;
      else
        if isempty(save)
          % the constructor attaches the registered default frame, which
          % specimenFrame.default seeds with plottingConvention.ij
          save = specimenSymmetry;
        end
        % the singleton always holds the session default frame - another
        % frame may have taken over via specimenFrame/makeDefault
        fr = specimenFrame.default;
        if save.frame ~= fr, save.frame = fr; end
        ss = save;
      end
    end
    
end
  

end
