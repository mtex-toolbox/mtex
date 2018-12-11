classdef crystalSymmetry < symmetry
% constructor
%
% Syntax
%   crystalSymmetry
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
%  axes  - [a,b,c] ~ length of the crystallographic axes
%  angle - [alpha,beta,gamma] ~ angle between the axes
%
% Output
%  s - @crystalSymmetry
%
% Description
% Supported Symmetries
%
%  id crystal system  Schoen-  Inter-    Laue     Rotational
%                     flies    national  class    axes
%  1  triclinic       C1       1         -1       1
%  2  triclinic       Ci       -1        -1       1
%  3  monoclinic      C2       2         2/m      2
%  4  monoclinic      Cs       m         2/m      2
%  5  monoclinic      C2h      2/m       2/m      2
%  6  orthorhombic    D2       222       mmm      222
%  7  orthorhombic    C2v      mm2       mmm      222
%  8  orthorhombic    D2h      mmm       mmm      222
%  9  tetragonal      C4       4         4/m      4
%  10 tetragonal      S4       -4        4/m      4
%  11 tetragonal      C4h      4/m       4/m      4
%  12 tetragonal      D4       422       4/mmm    422
%  13 tetragonal      C4v      4mm       4/mmm    422
%  14 tetragonal      D2d      -42m      4/mmm    422
%  15 tetragonal      D4h      4/mmm     4/mmm    422
%  16 trigonal        C3       3         -3       3
%  17 trigonal        C3i      -3        -3       3
%  18 trigonal        D3       32        -3m      32
%  19 trigonal        C3v      3m        -3m      32
%  20 trigonal        D3d      -3m       -3m      32
%  21 hexagonal       C6       6         6/m      6
%  22 hexagonal       C3h      -6        6/m      6
%  23 hexagonal       C6h      6/m       6/m      6
%  24 hexagonal       D6       622       6/mmm    622
%  25 hexagonal       C6v      6mm       6/mmm    622
%  26 hexagonal       D3h      -6m2      6/mmm    622
%  27 hexagonal       D6h      6/mmm     6/mmm    622
%  28 cubic           T        23        m-3      23
%  29 cubic           Th       m-3       m-3      23
%  30 cubic           O        432       m-3m     432
%  31 cubic           Td       -43m      m-3m     432
%  32 cubic           Oh       m-3m      m-3m     432
  
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
    
      s = s@symmetry(varargin{:});
                  
      if nargin > 1
        if ischar(varargin{1}) && any(strcmpi(varargin{1},{'pointId','LaueId','spaceId'}))
          varargin(1:2) = [];
        else
          varargin(1) = [];
        end
      end
        
        
      % get axes length (a b c)
      if ~isempty(varargin) && isa(varargin{1},'double')
        abc = varargin{1};
        varargin(1) = [];
      else 
        abc = [1,1,1];
      end
      
      % get axes angles (alpha beta gamma)
      if ~isempty(varargin) && isa(varargin{1},'double') && ...
          s.id < 12
        angles = varargin{1};
        if any(angles>2*pi), angles = angles * degree;end
        varargin(1) = [];
      elseif s.id>0 && any(strcmp(symmetry.pointGroups(s.id).lattice,{'trigonal','hexagonal'}))
        angles = [90 90 120] * degree;
      else
        angles = [90 90 90] * degree;
      end

      % compute coordinate system
      s.axes = calcAxis(s,abc,angles,varargin{:});
      
      s.mineral = get_option(varargin,'mineral','');
      s.color = get_option(varargin,'color','');
      
      if check_option(varargin,'density')
        s.opt.density = get_option(varargin,'density','');
      end
      
      % compute symmetry operations
      s = calcQuat(s,s.axes);
            
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
      a = Miller(1,0,0,cs,'hkl');
    end

    function b = get.bAxisRec(cs)
      b = Miller(0,1,0,cs,'hkl');
    end

    function c = get.cAxisRec(cs)
      c = Miller(0,0,1,cs,'hkl');
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
      
      if ~isempty(getMTEXpref('bAxisDirection',[]))
        rho = -cs.bAxis.rho + pi/2*(NWSE(getMTEXpref('bAxisDirection',[]))-1);
      elseif ~isempty(getMTEXpref('aAxisDirection',[]))
        rho = -cs.aAxis.rho + pi/2*(NWSE(getMTEXpref('aAxisDirection',[]))-1);
      else
        rho = 0;
      end
      opt = {'xAxisDirection',rho,'zAxisDirection','outOfPlane'};
    end
    
  end
    
end

