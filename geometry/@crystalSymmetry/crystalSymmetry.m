classdef crystalSymmetry < symmetry
%
% Syntax
%   crystalSymmetry('cubic')
%   crystalSymmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase')
%   crystalSymmetry('O')
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
%
% See also
% CrystalSymmetries CrystalShapes CrystalReferenceSystem CrystalOperations

  properties
    axes = [xvector,yvector,zvector]; % coordinate system
    mineral = ''                      % mineral name
    color = ''                        % color used for EBSD / grain plotting
  end

  properties (Dependent = true)
      
    alpha       % angle between b and c
    beta        % angle between c and a
    gamma       % angle between a and b
    aAxis       % a-axis
    bAxis       % b-axis
    cAxis       % c-axis
    aAxisRec    % a*-axis reciprocal coordinate system
    bAxisRec    % b*-axis reciprocal coordinate system
    cAxisRec    % c*-axis reciprocal coordinate system
    plotOptions
  end
  
  methods
    
    function s = crystalSymmetry(varargin)

      % this is for compatibility with using "strings" as input
      try varargin = controllib.internal.util.hString2Char(varargin); catch, end

      % define the symmetry just by rotations
      if nargin == 0
        
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
        if ~isempty(varargin) && isa(varargin{1},'double')
          abc = varargin{1};
          varargin(1) = [];
        else
          abc = [1,1,1];
        end
      
        % extract axes angles (alpha beta gamma)
        lattice = symmetry.pointGroups(id).lattice;
        angles = lattice.defaultAngles;
        
        if ~isempty(varargin) && isa(varargin{1},'double')
          angles = varargin{1};
          if any(angles>2*pi), angles = angles * degree; end
          varargin(1) = [];
        end
        
        % compute coordinate system
        axes = calcAxis(id,abc,angles,varargin{:});

        % compute symmetry operations
        rot = getClass(varargin,'quaternion');
        if isempty(rot), rot = symmetry.calcQuat(id,axes); end
         
      end
     
      % define the symmetry
      s = s@symmetry(id,rot);
      
      % set axes, mineral name and color
      s.axes = axes;
      s.mineral = get_option(varargin,'mineral','');
      s.color = get_option(varargin,'color','');
      
      if check_option(varargin,'density')
        s.opt.density = get_option(varargin,'density','');
      end
      
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
      b = Miller(0,1,0,cs);
    end

    function c = get.cAxisRec(cs)
      c = Miller(0,0,1,cs);
    end

    function alpha = get.alpha(cs)
      alpha = angle(cs.axes(2),cs.axes(3));
    end
    
    function beta = get.beta(cs)
      beta = angle(cs.axes(3),cs.axes(1));
    end
    
    function gamma = get.gamma(cs)
      gamma = angle(cs.axes(1),cs.axes(2));
    end    
   
    function opt = get.plotOptions(cs)
      % rotate the aAxis or bAxis into the right direction
      
      if ~isempty(getMTEXpref('aStarAxisDirection',[]))
        cor = pi/2*(NWSE(getMTEXpref('aStarAxisDirection',[]))-1);
        rho = -cs.aAxisRec.rho + cor;
      elseif ~isempty(getMTEXpref('bAxisDirection',[]))
        rho = -cs.bAxis.rho + pi/2*(NWSE(getMTEXpref('bAxisDirection',[]))-1);
      elseif ~isempty(getMTEXpref('aAxisDirection',[]))
        rho = -cs.aAxis.rho + pi/2*(NWSE(getMTEXpref('aAxisDirection',[]))-1);
      else
        rho = 0;
      end
      opt = {'xAxisDirection',rho,'zAxisDirection','outOfPlane'};
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
      if isa(s,'crystalSymmetry'), cs = s; return; end
      
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
            
      cs = crystalSymmetry(rot,id{:},axes);
      
      if isfield(s,'mineral'), cs.mineral = s.mineral; end
      if isfield(s,'color'), cs.color = s.color; end
      if isfield(s,'opt'), cs.opt = s.opt; end
            
    end
    
    
  end
    
end

