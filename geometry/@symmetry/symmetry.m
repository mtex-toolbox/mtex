classdef symmetry
%
% a point group - the symmetry elements and the id that names them
%
% A group says nothing about where it acts. Which coordinate system its
% elements are written in, and whether that system is a crystal or a
% specimen, is the business of the @referenceFrame that carries the group,
% see docs/adr/0008-frames-carry-symmetry.md.
%
% Class Properties
%  id         - point group id, compare to symmetry.pointGroups
%  rot        - the symmetry elements as @rotation
%  name       - international symbol of the point group
%  lattice    - the lattice type the group implies
%
% Derived Classes
%  @crystalSymmetry -
%  @specimenSymmetry -
%
% See also
% referenceFrame crystalSymmetry specimenSymmetry
%

  properties %(SetAccess = immutable)
    id = 1;               % point group id, compare to symList
    rot = rotation.id     % the symmetry elements
  end

  properties
    % the order of the symmetry axis along Z, and the highest order of an
    % axis perpendicular to it. Both follow from rot and are computed with
    % it, since a group does not change after it is built and the Wigner
    % transform asks for them once per call
    multiplicityZ = 1
    multiplicityPerpZ = 1
  end

  properties
    opt = struct
  end


  properties (Dependent = true)
    lattice          % type of crystal lattice
    pointGroup       % point group name
    name             % international symbol of the point group
  end

  properties (Constant = true)
    pointGroups = pointGroupList % list of all point groups
  end

  methods

    function s = symmetry(id,rot)
      % constructor

      if nargin == 0, return; end

      s.id = id;
      if nargin > 1 && ~isempty(rot), s.rot = rot; end

    end


    function s = set.rot(s,rot)
      % everything derived from the group elements is computed with them
      s.rot = rot;
      s.multiplicityZ = axisOrder(rot,true);
      s.multiplicityPerpZ = axisOrder(rot,false);
    end


    function pg = get.pointGroup(sym)
      if sym.id>0
        pg = symmetry.pointGroups(sym.id).Inter;
      else
        pg = 'unknown';
      end
    end

    function n = get.name(sym)
      % a group is named by its international symbol, the way a frame is
      % named by its mineral - so frame.name and frame.sym.name are the
      % phase and the group side by side
      n = sym.pointGroup;
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



% ---------------------------------------------------------------

function n = axisOrder(rot,alongZ)
% the order of the highest symmetry axis parallel or perpendicular to Z

d = dot(rot.axis,zvector);
if alongZ
  sel = isnull(1-abs(d)) & ~isnull(rot.angle);
else
  sel = isnull(d,1e-4) & ~isnull(rot.angle,1e-4);
end

if any(sel(:))
  n = round(2*pi/min(abs(angle(rot(sel)))));
else
  n = 1;
end

end
