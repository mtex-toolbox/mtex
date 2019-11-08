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
%  axes - @vector3d 
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
  end
    
end

