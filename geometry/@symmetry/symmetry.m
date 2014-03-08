classdef symmetry < rotation
% constructor
%
%
% Input
%  name  - Schoenflies or International notation of the Laue group
%  axes  - [a,b,c] --> length of the crystallographic axes
%  angle - [alpha,beta,gamma] --> angle between the axes
%
% Syntax
% symmetry -
% symmetry('cubic') -
% symmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase') -
% symmetry('O') -
% symmetry('LaueId',9) -
% symmetry('SpaceId',153) -
%
% Output
%  s - @symmetry
%
% Remarks
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

    isCS = false; % is crystal symmetry
    axes = [xvector,yvector,zvector]; % coordinate system
    mineral = '';                     % mineral name
    id = 1;                           % point group id, compare to symList
    color = '';                       % color used for EBSD plotting    
  end

  properties (Dependent = true)
      
    alpha       % angle between b and c
    beta        % angle between c and a
    gamma       % angle between a and b
    pointGroup  % name of the point group
    lattice     % type of crystal lattice 
    isLaue      % is it a Laue group
    isProper   % does it contain only proper rotations
  end
  
  properties (Constant = true)
    
    pointGroups = pointGroupList % list of all point groups
    
  end
    
  methods
    
    function s = symmetry(varargin)
    
      s = s@rotation(idquaternion);
      
      % empty constructor
      if nargin == 0, return; end
      
      if check_option(varargin,'LaueId')
      
        % -1 2/m mmm 4/m 4/mmm m-3 m-3m -3 -3m 6/m 6/mmm
        LaueGroups = [2,5,8,11,15,29,32,17,20,22,27];
        s.id = LaueGroups(get_option(varargin,'LaueId'));
        varargin = delete_option(varargin,'LaueId');
      
      elseif check_option(varargin,'SpaceId')
        
        list = spaceGroups;
        ndx = nnz([list{:,1}] < get_option(varargin,'SpaceId'));
        varargin = delete_option(varargin,'SpaceId');
        if ndx>31, error('I''m sorry, I know only 230 space groups ...'); end
        s.id = ndx+1;
        
      else

        try
          s.id = findsymmetry(varargin{1});
          varargin(1) = [];
        catch %#ok<CTCH>
          
          if check_option(varargin,'noCIF')
            error('symmetry "%s" not found',pGroup);
          end
  
          % may be it is a cif file
          try
            s = loadCIF(varargin{:});
            return;
          catch %#ok<CTCH>
            if ~check_option(varargin,'silent')
              help symmetry;
              error('symmetry "%s" not found',varargin{1});
            end
          end
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
          s.id <= 5
        angles = varargin{1};
        if any(angles>2*pi), angles = angles * degree;end
        varargin(1) = [];
      elseif any(strcmp(symmetry.pointGroups(s.id).lattice,{'trigonal','hexagonal'}))
        angles = [90 90 120] * degree;
      else
        angles = [90 90 90] * degree;
      end

      % compute coordinate system
      s.axes = calcAxis(abc,angles,varargin{:});
      
      s.mineral = get_option(varargin,'mineral','');
      s.color = get_option(varargin,'color','');
      
      % compute symmetry operations
      r = calcQuat(s.LaueName,s.axes,symmetry.pointGroups(s.id).Inversion);
      [s.a, s.b, s.c, s.d] = double(r);
      s.i = isImproper(r);
      
      % decide crystal / specimen symmetry
      if check_option(varargin,'specimen')
        s.isCS = false;
      elseif check_option(varargin,'crystal')
        s.isCS = true;
      else
        s.isCS = ~(numel(s.a)<=8 && all(isnull(norm(s.axes-[xvector,yvector,zvector]))));
      end
      
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
    
    function pg = get.pointGroup(cs)
      pg = symmetry.pointGroups(cs.id).Inter;
    end
    
    function l = get.lattice(cs)
      l = symmetry.pointGroups(cs.id).lattice;
    end
    
    function r = get.isLaue(cs)
      r = cs.id == symmetry.pointGroups(cs.id).LaueId;
    end
    
    function r = get.isProper(cs)
      r = ~any(cs.i(:));
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


