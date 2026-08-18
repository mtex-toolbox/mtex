classdef symmetry < matlab.mixin.Copyable
%
% symmetry is an abstract class for crystal and specimen symmetries
%
% Derived Classes
%  @crystalSymmetry - 
%  @specimenSymmetry - 
%

  properties %(SetAccess = immutable)
    id = 1;               % point group id, compare to symList    
    rot = rotation.id     % the symmetry elements
  end
  
  properties
    multiplicityPerpZ = 1
  end
  
  properties
    opt = struct
    frame = []       % the referenceFrame this symmetry is attached to
  end


  properties (Dependent = true)
    lattice          % type of crystal lattice
    pointGroup       % point group name
    how2plot         % plotting convention - read only
    % A convention belongs to a reference frame. To change how this is
    % drawn use plot(...,'y↑→x') for one plot,
    % plottingConvention.default(...) for the session, or move the data
    % with x.frame = specimenFrame.rolling
  end
  
  properties (Access = protected)
    LaueRef = []
    properRef = []
  end

  properties (Access = protected, Transient = true)
    % cache for stripSym: the trivial stand-in must be a stable handle, since
    % crystalSymmetry equality is sealed to handle identity - never saved
    stripSymRef = []

    % cache for multiplicityZ: computing it builds the axes of the whole
    % group, and the Wigner transform asks for it on every single call.
    % Cleared by set.rot, since the multiplicity follows the group elements
    multiplicityZRef = []
  end
    
  properties (Constant = true)
    pointGroups = pointGroupList % list of all point groups
  end

  % this is an abstract class
  methods (Abstract = true)
    display(s)
    dispLine(s)
  end
  
  methods
       
    function s = symmetry(id,rot,pC)
      % constructor
      
      s.id = id;
      if ~isempty(rot), s.rot = rot; end

      % kept for backward compatibility: an explicitly passed convention
      % gets a frame carrying it; the subclass constructors mint a frame
      % that supplies the default instead
      if nargin == 3 && ~isempty(pC)
        s.frame = specimenSymmetry.frameFor(pC);
      end

      if s.id == 1, return; end
        
      isPerpZ = isnull(dot(rot.axis,zvector),1e-4) & ~isnull(rot.angle,1e-4);

      if any(isPerpZ(:))
        s.multiplicityPerpZ = round(2*pi/min(abs(angle(rot(isPerpZ)))));
      else
        s.multiplicityPerpZ = 1;
      end

    end
    
    
    function s = set.rot(s,rot)
      % replacing the group elements invalidates everything derived from
      % them - properGroup/properSubGroup/makeLaue all work this way
      s.rot = rot;
      s.multiplicityZRef = [];
    end


    function pC = get.how2plot(s)
      % only frames carry conventions - a symmetry shows the one of its
      % reference frame
      pC = [];
      if ~isempty(s.frame), pC = s.frame.how2plot; end
    end


    function pg = get.pointGroup(sym)
      if sym.id>0
        pg = symmetry.pointGroups(sym.id).Inter;
      else
        pg = 'unknown';
      end
    end
        
    function lattice = get.lattice(sym)
      if sym.id>0
        lattice = symmetry.pointGroups(sym.id).lattice;
      else
        lattice = latticeType.none;
      end
    end
    
    function out = le(cs1,cs2)
      % check whether cs1 is a sub group of cs2
      out = all(any(abs(dot_outer(cs1.rot,cs2.rot))>1-1e-6,2));
    end
    
    function out = ge(cs1,cs2)
      % check whether cs2 is a sub group of cs1
      out = le(cs2,cs1);
    end
        
    function out = lt(cs1,cs2)
      % check whether cs1 is a true sub group of cs2
      out = le(cs1,cs2) & ~le(cs2,cs1);
    end
    
    function out = gt(cs1,cs2)
      % check whether cs2 is a true sub group of cs1
      out = lt(cs2,cs1);
    end

    function out = stripSym(sym)
      % the trivial group in the reference frame of the input - the
      % symmetry is dropped, where the data lives is not
      %
      % the stand-in is cached on the input handle: crystalSymmetry
      % equality is sealed to handle identity, so repeated drops of the
      % same symmetry must return the same handle to stay comparable

      if sym.id == 1, out = sym; return; end

      out = sym.stripSymRef;

      % invalidate when the frame was replaced - handle identity, since
      % an equal-valued fork is a different frame
      if ~isempty(out)
        sameFrame = (isempty(sym.frame) && isempty(out.frame)) || ...
          (~isempty(sym.frame) && ~isempty(out.frame) && out.frame == sym.frame);
        if ~sameFrame, out = []; end
      end

      if isempty(out)
        if isa(sym,'crystalSymmetry')
          out = crystalSymmetry;
          % the mineral doubles as the frame identity, so displays keep
          % saying whose frame the data lives in
          out.mineral = sym.mineral;
        elseif isa(sym,'specimenSymmetry')
          out = specimenSymmetry;
        end
        out.frame = sym.frame;
        sym.stripSymRef = out;
      end
    end
    
  end

  methods (Hidden = true, Static = true)
    
    
    function [id, varargin] = extractPointId(varargin)

      % determine the correct id
      if nargin == 0
      
        id = 1;
              
      elseif check_option(varargin,'PointId')
        
        id = get_option(varargin,'PointId');
        
      elseif check_option(varargin,'LaueId')
      
        % -1 2/m mmm 4/m 4/mmm m-3 m-3m -3 -3m 6/m 6/mmm
        LaueGroups = [2,8,16,27,32,42,45,18,21,35,40];
        id = LaueGroups(get_option(varargin,'LaueId'));
              
      elseif check_option(varargin,'SpaceId')
        
        list = spaceGroups;
        ndx = nnz([list{:,1}] < get_option(varargin,'SpaceId'));
        assert(ndx <= 31, 'I''m sorry, I know only 230 space groups ...');
        id = findsymmetry(list(ndx+1,2));
        
      else

        str = varargin{1};
  
        % expand 2, m, and 2/m to 112 or 121 or 211 depending on the angles
        if any(strcmp(str,{'2','m','2/m'})) && nargin > 2 && isnumeric(varargin{3})
          
          abg = varargin{3};
          if max(abg) > 2*pi, abg = abg * degree; end
          
          [~,i] = max(abs(abg-pi/2));
          
          p = {'1','1','1'};
          p{i} = str;
          str = [p{:}];
          
        end
        
        id = findsymmetry(str);
        varargin(1) = [];
  
      end

      % remove from varargin
      varargin = delete_option(varargin,{'PointId','LaueId','SpaceId'},1);
    end

    
    function id = rot2pointId(rot,varargin)
      % find a symmetry that exactly contains s
      
      axes = getClass(varargin,'vector3d');
      if isempty(axes), axes = [xvector,yvector,zvector]; end
      
      for id=1:45 % check all point groups
        rotId = symmetry.calcQuat(id,axes);
        if length(rot) == length(rotId) && all(any(isappr(abs(dot_outer(rotId,rot)),1)))
          return
        end
      end
      id = 0;
    end
    
    
    function rot = calcQuat(id,varargin)
      % calculate symmetry elements

      axes = getClass(varargin,'vector3d');
      if isempty(axes), axes = [xvector,yvector,zvector]; end

      a = axes(1); b = axes(2); c = axes(3);

      a1 = axes(1); a2 = axes(2); m = a1 - a2;

      ll0axis = a+b; lllaxis = a+b+c;

      pg = pointGroupList;
      pg = pg(id);

      % compute rotations
      switch pg.LaueId
        case 2 % 1
          rot = {rotation.id};
        case 5 % 211
          rot = {symAxis(a,2)};
        case 8 % 121
          rot = {symAxis(b,2)};
        case 11 % 112
          rot = {symAxis(c,2)};
        case 16 % 222
          rot = {symAxis(a,2),symAxis(c,2)};
        case 18 % 3
          rot = {symAxis(c,3)};
        case 21 % 321
          rot = {symAxis(a1,2),symAxis(c,3)};
        case 24 % 312
          rot = {symAxis(m,2),symAxis(c,3)};
        case 27 % 4
          rot = {symAxis(c,4)};
        case 32 % 4/mmm
          rot = {symAxis(a,2),symAxis(c,4)};
        case 35 % 6
          rot = {symAxis(c,6)};
        case 40 % 622
          rot = {symAxis(a,2),symAxis(c,6)};
        case 42 % 23
          rot = {symAxis(lllaxis,3),symAxis(a,2),symAxis(c,2)};
        case 45 % 432
          rot = {symAxis(lllaxis,3),symAxis(ll0axis,2),symAxis(c,4)};
        case 47 % 532
          a5 = c + 2/(1+sqrt(5)) * a;
          rot = {symAxis(a5,5),symAxis(a,2),symAxis(b,2),symAxis(c,2)};
      end

      % apply inversion
      if size(pg.Inversion ,1) == 2
        rot = [rot,{[1,-1] .* rotation.id}];
      else
        rot = arrayfun(@(i) rot{i} .* pg.Inversion(i).^(0:length(rot{i})-1) ,...
          1:length(rot),'uniformOutput',false);
      end

      % store symmetries
      rot = prod(rot{:});
      if pg.LaueId == 47, rot = unique(rot*rot,'exact'); end

    end

  end
  
end




% ---------------------------------------------------------------

function list = spaceGroups

list = { 1,    '1';
  2,   '-1';
  5,    '2';
  9,    'm';
  15,   '2/m';
  24,    '222';
  46,    'mm2';
  74,   'mmm';
  80,    '4';
  82,    '-4';
  88,   '4/m';
  98,    '422';
  110,    '4mm';
  122,   '-42m';
  142,    '4/mmm';
  146,    '3';
  148,   '-3';
  155,    '32';
  161,    '3m';
  167,   '-3m';
  173,    '6';
  174,    '-6';
  176,    '6/m';
  182,   '622';
  186,   '6mm';
  190,  '-6m2';
  194, '6/mmm';
  199,    '23';
  206,   'm-3';
  214,   '432';
  220,  '-43m';
  230,  'm-3m'};
end


