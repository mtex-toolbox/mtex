function s = symmetry(name,varargin)
% constructor
%
%
%% Input
%  name  - Schoenflies or International notation of the Laue group
%  axis  - [a,b,c] --> length of the crystallographic axes
%  angle - [alpha,beta,gamma] --> angle between the axes
%
%% Syntax
% symmetry -
% symmetry('cubic') -
% symmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase') -
% symmetry('O') -
% symmetry(9) -
% symmetry('spacegroup',153) -
%
%% Output
%  s - @symmetry
%
%% Remarks
% Supported Symmetries
%
%  crystal system  Schoen-  Inter-    Laue     Rotational
%                  flies    national  class    axis
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

%% get input

if nargin == 0
  s.name = 'triclinic';
  s.laue = '-1';
  s.axis =  [xvector,yvector,zvector];
  s.mineral = '';
  s.color = '';
  s = class(s,'symmetry',rotation(idquaternion));
  return
end

if isa(name,'symmetry'),  s = name;return;end
if isa(name,'double')
  LaueGroups =  {'C1','C2','D2','C4','D4','T','O','C3','D3','C6','D6'};
  name = LaueGroups{name};
  
elseif strncmp(name,'spacegroup',10) && nargin > 1
    
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
    230,  'm-3m';};
  ndx = nnz([list{:,1}] < varargin{1});
  
  if ndx>31
    error('I''m sorry, I know only 230 space groups ...')
  end
  varargin = varargin(2:end);
  name = list{ndx+1,2};
  
end



%% search for symmetry

% maybe this is a point group
try
  sym = findsymmetry(name);
catch %#ok<*CTCH>
  
  if check_option(varargin,'noCIF')
    error('symmetry "%s" not found',name);
  end
  
  % maybe it is a space group
  try
    sym = findsymmetry(hms2point(name));
  catch
    try % may be it is a cif file
      s = loadCIF(name,varargin{:});
      return;
    catch
    end
    if ~check_option(varargin,'silent')
      help symmetry;
      error('symmetry "%s" not found',name);
    end
  end
end


if ~isempty(varargin) && isa(varargin{1},'double')
  axis = varargin{1};
  varargin(1) = [];
else
  axis = [1 1 1];
end
if ~isempty(varargin) && isa(varargin{1},'double') && any(strcmp(sym.Laue,{'-1','2/m'}))
  angle = varargin{1};
  if any(angle>2*pi), angle = angle * degree;end
  varargin(1) = [];
elseif any(strcmp(sym.System,{'trigonal','hexagonal'}))
  angle= [90 90 120] * degree;
else
  angle= [90 90 90] * degree;
end


%% set up symmetry
s.name = name;
s.laue = sym.Laue;
s.axis = calcAxis(axis,angle,varargin{:});
s.mineral = get_option(varargin,'mineral','');
s.color = get_option(varargin,'color','');

s = class(s,'symmetry',rotation(calcQuat(s.laue,s.axis)));
