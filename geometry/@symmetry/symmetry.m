function s = symmetry(name,varargin)
% constructor
%
%% Input
%  name  - Schoenflies or International notation of the Laue group
%  axis  = [a,b,c] -> length of the crystallographic axes
%  angle = [alpha,beta,gamma] -> angle between the axes
%
%% Output
%  s - @symmetry
%
%% Supported Symmetries  
%
%  crystal system  Schoen-  Inter-    Laue     Rotational 
%  flies    national  class    axis
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
  s.name = '1';
  s.laue = '-1';
  s.axis =  [xvector,yvector,zvector];
  s.quat = idquaternion;
  s.mineral = '';
  superiorto('quaternion','SO3Grid');
  s = class(s,'symmetry');
  return
end

if isa(name,'symmetry'),  s = name;return;end
if ~isempty(varargin) && isa(varargin{1},'double')
  axis = varargin{1};
  varargin(1) = [];
else
  axis = [1 1 1]; 
end
if ~isempty(varargin) && isa(varargin{1},'double')
  angle = varargin{1};
  varargin(1) = [];
else
  angle= [90 90 90] * degree;  
end

%% search for symmetry
try
  sym = findsymmetry(name);
catch %#ok<*CTCH>
  
  % maybe it is a point group
  try
    sym = findsymmetry(hms2point(name));
  catch
    help symmetry;
    error('symmetry "%s" not found',name);
  end
end

%% set up symmetry
s.name = name;
s.laue = sym.Laue;
s.axis = calcAxis(sym.System,axis,angle,varargin{:});
s.quat = calcQuat(s.laue,s.axis);
s.mineral = get_option(varargin,'mineral','');

superiorto('quaternion','SO3Grid','orientation');
s = class(s,'symmetry');
