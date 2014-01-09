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
% symmetry(9) -
% symmetry('spacegroup',153) -
%
% Output
%  s - @symmetry
%
% Remarks
% Supported Symmetries
%
%  crystal system  Schoen-  Inter-    Laue     Rotational
%                  flies    national  class    axes
%  triclinic       C1       1         -1       1
%  triclinic       Ci       -1        -1       1
%  monoclinic      C2       2         2/m      2
%  monoclinic      Cs       m         2/m      2
%  monoclinic      C2h      2/m       2/m      2
%  orthorhombic    D2       222       mmm      222
%  orthorhombic    C2v      mm2       mmm      222
%  orthorhombic    D2h      mmm       mmm      222
%  tetragonal      C4       4         4/m      4
%  tetragonal      S4       -4        4/m      4
%  tetragonal      C4h      4/m       4/m      4
%  tetragonal      D4       422       4/mmm    422
%  tetragonal      C4v      4mm       4/mmm    422
%  tetragonal      D2d      -42m      4/mmm    422
%  tetragonal      D4h      4/mmm     4/mmm    422
%  trigonal        C3       3         -3       3
%  trigonal        C3i      -3        -3       3
%  trigonal        D3       32        -3m      32
%  trigonal        C3v      3m        -3m      32
%  trigonal        D3d      -3m       -3m      32
%  hexagonal       C6       6         6/m      6
%  hexagonal       C3h      -6        6/m      6
%  hexagonal       C6h      6/m       6/m      6
%  hexagonal       D6       622       6/mmm    622
%  hexagonal       C6v      6mm       6/mmm    622
%  hexagonal       D3h      -6m2      6/mmm    622
%  hexagonal       D6h      6/mmm     6/mmm    622
%  cubic           T        23        m-3      23
%  cubic           Th       m-3       m-3      23
%  cubic           O        432       m-3m     432
%  cubic           Td       -43m      m-3m     432
%  cubic           Oh       m-3m      m-3m     432
  
  properties

    isCS = false; % is crystal symmetry
    pointGroup = 'triclinic';
    laueGroup  = '-1';
    axes = [xvector,yvector,zvector];
    mineral = '';
    color = '';
    
  end
  
  methods
    
    function s = symmetry(varargin)
    
      s = s@rotation(idquaternion);
      
      if nargin == 0 % empty constructor
        return;
      elseif isa(varargin{1},'symmetry') % copy constructor
        s = varargin{1};
        return
      end
      
      % determine point group
      if isa(varargin{1},'double') % point group by number
  
        LaueGroups =  {'-1','2/m','mmm','4/m','4/mmm','m-3','m-3m','-3','-3m','6/m','6/mmm'};
        pGroup = LaueGroups{varargin{1}};
        
      elseif strncmp(varargin{1},'spacegroup',10) && nargin > 1 % space group by number
  
        list = spaceGroups;
        ndx = nnz([list{:,1}] < varargin{1});
  
        if ndx>31
          error('I''m sorry, I know only 230 space groups ...')
        end
        varargin = varargin(2:end);
        pGroup = list{ndx+1,2};
        
      else % given by its name
        
        pGroup = varargin{1};
        
      end
        
      % search for pointgroup
      try
        sym = findsymmetry(pGroup);
      catch
        sym = [];
      end

      % nothing found?
      if isempty(sym)
                   
        if check_option(varargin,'noCIF'), error('symmetry "%s" not found',pGroup); end
  
        % may be it is a cif file
        try
          s = loadCIF(varargin{:});
          return;
        catch %#ok<CTCH>
          if ~check_option(varargin,'silent')
            help symmetry;
            error('symmetry "%s" not found',pGroup);
          end
        end
      end
      varargin(1) = [];

      % get axes length (a b c)
      if ~isempty(varargin) && isa(varargin{1},'double')
        abc = varargin{1};
        varargin(1) = [];
      else 
        abc = [1,1,1];
      end
      
      % get axes angles (alpha beta gamma)
      if ~isempty(varargin) && isa(varargin{1},'double') && any(strcmp(sym.Laue,{'-1','2/m'}))
        angles = varargin{1};
        if any(angles>2*pi), angles = angles * degree;end
        varargin(1) = [];
      elseif any(strcmp(sym.System,{'trigonal','hexagonal'}))
        angles = [90 90 120] * degree;
      else
        angles = [90 90 90] * degree;
      end

      % compute coordinate system
      s.axes = calcAxis(abc,angles,varargin{:});
      
      
      % set up symmetry
      s.pointGroup = pGroup;
      s.laueGroup = sym.Laue;
      
      s.mineral = get_option(varargin,'mineral','');
      s.color = get_option(varargin,'color','');
      
      % compute symmetry operations
      r = calcQuat(s.laueGroup,s.axes,sym.Inversion);
      [s.a, s.b, s.c, s.d] = double(r);
      s.i = isImproper(r);
      
      % decide crystal / specimen symmetry
      if check_option(varargin,'specimen')
        s.isCS = false;
      elseif check_option(varargin,'crystal')
        s.isCS = true;
      else
        s.isCS = ~(numel(s.a)<=4 && all(isnull(norm(s.axes-[xvector,yvector,zvector]))));
      end
      
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
  110,    '4/mmm';
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


