classdef crystalSymmetry < symmetry & phaseItem
%
% Syntax
%   crystalSymmetry('cubic')
%   crystalSymmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase')
%   crystalSymmetry('O')
%   crystalSymmetry(cF) % the trivial group carrying the crystalFrame cF
%   crystalSymmetry('LaueId',9)
%   crystalSymmetry('SpaceId',153)
%   rot = rotation.map(vector3d(1,1,1),vector3d.Z,vector3d(0,-1,1),vector3d.X)
%   crystalSymmetry('432','rotAxes',rot)
%
% Input
%  name  - Schoenflies or International notation of the Laue group
%  axes  - [a,b,c] - length of the crystallographic axes
%  angle - [alpha,beta,gamma] - angle between the axes
%
% Options
%  X||a*, Z||c - default alignment of the cartesian coordinate system to the crystal coordinate system
%  X||a, Z||c* - other alignments
%  X||b*, Z||c -
%  X||b, Z||c* -
%  EDAX - the alignment convention used by EDAX / TSL / OIM, i.e. X||a for
%    triclinic, trigonal and hexagonal lattices and the MTEX default otherwise
%
% Class Properties 
%  id                           - point group id
%  pointGroup                   - international notation of the point group
%  lattice                      - lattice type
%  isLaue                       - is Laue group?
%  isProper                     - is enantiomorphic group?
%  mineral                      - mineral name
%  color                        - color used in EBSD phase plot
%  alpha, beta, gamma           - angles between the a, b and c axis
%  aAxis, bAxis, cAxis          - direct crystal axes @Miller
%  aAxisRec, bAxisRec, cAxisRec - reciprocal crystal axes @Miller
%  axes                         - @vector3d 
%
% See also
% CrystalSymmetries CrystalShapes CrystalReferenceSystem CrystalOperations
%

% Supported Symmetries
%
%  id  crystal system  Schoen-  Inter-    Laue     Rotational
%                      flies    national  class    axes
%  1   triclinic       C1       1         -1       1
%  2   triclinic       Ci       -1        -1       1
%  3   monoclinic      C2       211       2/m11    211
%  4   monoclinic      Cs       m11       2/m11    211
%  5   monoclinic      C2h      2/m11     2/m11    211
%  6   monoclinic      C2       121       12/m1    121
%  7   monoclinic      Cs       1m1       12/m1    121
%  8   monoclinic      C2h      12/m1     12/m1    121
%  9   monoclinic      C2       112       112/m    112
%  10  monoclinic      Cs       11m       112/m    112
%  11  monoclinic      C2h      112/m     112/m    112
%  12  orthorhombic    D2       222       mmm      222
%  13  orthorhombic    C2v      2mm       mmm      222
%  14  orthorhombic    C2v      m2m       mmm      222
%  15  orthorhombic    C2v      mm2       mmm      222
%  16  orthorhombic    D2h      mmm       mmm      222
%  17  trigonal        C3       3         -3       3
%  18  trigonal        C3i      -3        -3       3
%  19  trigonal        D3       321       -3m1     321
%  20  trigonal        C3v      3m1       -3m1     321
%  21  trigonal        D3d      -3m1      -3m1     321
%  22  trigonal        D3       312       -31m     312
%  23  trigonal        C3v      31m       -31m     312
%  24  trigonal        D3d      -31m      -31m     312
%  25  tetragonal      C4       4         4/m      4
%  26  tetragonal      S4       -4        4/m      4
%  27  tetragonal      C4h      4/m       4/m      4
%  28  tetragonal      D4       422       4/mmm    422
%  29  tetragonal      C4v      4mm       4/mmm    422
%  30  tetragonal      D2d      -42m      4/mmm    422
%  31  tetragonal      D2d      -4m2      4/mmm    422
%  32  tetragonal      D4h      4/mmm     4/mmm    422
%  33  hexagonal       C6       6         6/m      6
%  34  hexagonal       C3h      -6        6/m      6
%  35  hexagonal       C6h      6/m       6/m      6
%  36  hexagonal       D6       622       6/mmm    622
%  37  hexagonal       C6v      6mm       6/mmm    622
%  38  hexagonal       D3h      -62m      6/mmm    622
%  39  hexagonal       D3h      -6m2      6/mmm    622
%  40  hexagonal       D6h      6/mmm     6/mmm    622
%  41  cubic           T        23        m-3      23
%  42  cubic           Th       m-3       m-3      23
%  43  cubic           O        432       m-3m     432
%  44  cubic           Td       -43m      m-3m     432
%  45  cubic           Oh       m-3m      m-3m     432
%  46  icosahedral     I        532       -5-32/m  532
%  47  icosahedral     Ih       -5-32/m   -5-32/m  532
%

  properties (Dependent = true)

    axes        % coordinate system - the basis of the crystalFrame
    alpha       % angle between b and c
    beta        % angle between c and a
    gamma       % angle between a and b
    aAxis       % a-axis
    bAxis       % b-axis
    cAxis       % c-axis
    abg         % alpha, beta, gamma
    abc         % a, b, c
    aAxisRec    % a*-axis reciprocal coordinate system
    bAxisRec    % b*-axis reciprocal coordinate system
    cAxisRec    % c*-axis reciprocal coordinate system
    X           % x-axis
    Y           % y-axis
    Z           % z-axis
  end
  
  methods
    
    function s = crystalSymmetry(varargin)

      % this is for compatibility with using "strings" as input
      try varargin = controllib.internal.util.hString2Char(varargin); catch, end

      % the trivial group carrying a given crystalFrame, see ADR 0003
      frameAdopted = nargin > 0 && isa(varargin{1},'crystalFrame');

      if frameAdopted

        fr = varargin{1};
        varargin(1) = [];
        id = 1;
        rot = rotation.id;

      % define the symmetry just by rotations
      elseif nargin == 0
        
        id = 1;
        axes = [xvector,yvector,zvector];
        rot = rotation.id;
        
      elseif isa(varargin{1},'quaternion')

        rot = rotation(varargin{1});
        axes = getClass(varargin,'vector3d',[xvector,yvector,zvector]);
      
        if check_option(varargin,'pointId')
          id = get_option(varargin,'pointId');
        else
          id = symmetry.rot2pointId(rot,axes);
        end
        
      else
        
        [id, varargin] = symmetry.extractPointId(varargin{:});
      
        % get axes length (a b c)
        if ~isempty(varargin) && isnumeric(varargin{1})
          abc = varargin{1};
          varargin(1) = [];
        else
          abc = [1,1,1];
        end
      
        % extract axes angles (alpha beta gamma)
        lattice = symmetry.pointGroups(id).lattice;
        angles = lattice.defaultAngles;
        
        if ~isempty(varargin) && isnumeric(varargin{1})
          angles = varargin{1};
          if any(angles>2*pi), angles = angles * degree; end
          varargin(1) = [];
        end
        
        % compute the reference frame - crystalFrame owns the axes
        % computation including the alignment options
        fr = crystalFrame(abc,angles,varargin{:},'pointId',id);
        axes = fr.basis;

        % compute symmetry operations
        rot = getClass(varargin,'quaternion');
        if isempty(rot), rot = symmetry.calcQuat(id,axes); end

      end

      % axes given directly - wrap them into a frame
      if ~exist('fr','var'), fr = crystalFrame(axes); end

      % define the symmetry
      s = s@symmetry(id,rot);

      % set mineral name and color - an adopted frame donates its name
      if frameAdopted
        s.mineral = get_option(varargin,'mineral',char(fr.name));
      else
        s.mineral = get_option(varargin,'mineral','');
      end
      s.mineral = strtrim(regexprep(s.mineral,char(0),' '));
      s.color = get_option(varargin,'color','');

      % the reference frame carries the axes, the mineral doubles as its identity
      if ~frameAdopted, fr.name = s.mineral; end
      s.frame = fr;

      if check_option(varargin,'density')
        s.opt.density = get_option(varargin,'density','');
      end

      % the plotting convention of the frame, unless an adopted frame carries one
      if ~frameAdopted || isempty(s.frame.how2plot)
        if id > 11 || id==0
          pC = plottingConvention(s.cAxisRec,s.aAxis);
        else
          pC = plottingConvention(s.cAxisRec,s.bAxis);
        end
        s.frame.how2plot = pC;
      end

    end

    function v = get.axes(cs)
      v = cs.frame.basis;
    end

    function set.axes(cs,v)
      % fork - never write the basis through a possibly shared frame
      % handle; carries name and convention over to the new frame
      if isempty(cs.frame)
        cs.frame = crystalFrame(v);
      else
        f = crystalFrame(v,'name',cs.frame.name);
        f.how2plot = cs.frame.how2plot;
        cs.frame = f;
      end
    end
    
    function x = get.X(cs)
      x = Miller(vector3d.X,cs,'xyz');
    end

    function y = get.Y(cs)
      y = Miller(vector3d.Y,cs,'xyz');
    end

    function z = get.Z(cs)
      z = Miller(vector3d.Z,cs,'xyz');
    end

    function a = get.aAxis(cs)
      a = Miller(1,0,0,cs,'uvw');
    end

    function b = get.bAxis(cs)
      b = Miller(0,1,0,cs,'uvw');
    end

    function c = get.cAxis(cs)
      c = Miller(0,0,1,cs,'uvw');
    end

    function a = get.aAxisRec(cs)
      a = Miller(1,0,0,cs);
    end

    function b = get.bAxisRec(cs)
      b = cs.axesDual;
      b = Miller(b(2),cs);
    end

    function c = get.cAxisRec(cs)
      c = cs.axesDual;
      c = Miller(c(3),cs);
    end

    function abg = get.abg(cs)
      abg = cs.frame.abg;
    end

    function abc = get.abc(cs)
      abc = cs.frame.abc;
    end

    function alpha = get.alpha(cs)
      alpha = cs.frame.alpha;
    end

    function beta = get.beta(cs)
      beta = cs.frame.beta;
    end

    function gamma = get.gamma(cs)
      gamma = cs.frame.gamma;
    end
   
  end
  
  methods (Static = true)
    cs = load(fname,varargin)
    
    cs = byElements(rot,varargin)
    
    function cs = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % maybe there is nothing to do
      if isa(s,'crystalSymmetry')
        if isempty(s.multiplicityPerpZ)
          isPerpZ = isnull(dot(s.rot.axis,zvector)) & ~isnull(s.rot.angle);

          if any(isPerpZ(:))
            s.multiplicityPerpZ = round(2*pi/min(abs(angle(s.rot(isPerpZ)))));
          else
            s.multiplicityPerpZ = 1;
          end
        end
        cs = s;

        if isempty(cs.color)
          color = getMTEXpref('colors');
          cs.color = color(1,:);
        elseif ischar(cs.color)
          cs.color = str2rgb(cs.color);
        end

        % a pre-frame object restored axes and how2plot through the
        % dependent setters, which minted and forked the frame
        if isempty(cs.frame), cs.frame = crystalFrame([xvector,yvector,zvector]); end
        cs.frame.name = cs.mineral;

        if isa(cs.how2plot,'plottingConvention'), return; end
      end
      
      if isfield(s,'rot') || isprop(s,'rot')
        rot = s.rot;
      else
        rot = rotation(s.a,s.b,s.c,s.d,s.i);
      end
      
      if isfield(s,'axes')  || isprop(s,'axes')
        axes = s.axes;
      else
        axes = [];
      end
      
      if isfield(s,'id')  || isprop(s,'id')
        id = {'pointId',s.id};
      else
        id = {};
      end
            
      cs = crystalSymmetry(rot,id{:},axes);
      
      if isfield(s,'mineral') || isprop(s,'mineral'), cs.mineral = s.mineral; end
      if isfield(s,'color') || isprop(s,'color'), cs.color = s.color; end
      if isfield(s,'opt') || isprop(s,'opt'), cs.opt = s.opt; end
      cs.frame.name = cs.mineral;
            
    end

    function cs = default(cs)
      persistent save
      if nargin == 1
        save =  cs;
      else
        if isempty(save)
          save = crystalSymmetry; 
        end
        cs = save;
      end
    end
    
    
  end
    
end

