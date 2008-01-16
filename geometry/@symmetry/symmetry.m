function s = symmetry(name,axis,angle)
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
%  tricline        C1       1         -1       1    
%  tricline        Ci       -1        -1       1    
%  monocline       C2       2         2/m      2    
%  monocline       Cs       m         2/m      2    
%  monocline       C2h      2/m       2/m      2    
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


if nargin == 0, name = '1';end
if isa(name,'symmetry'),  s = name;return;end
if nargin <= 1, axis = [1 1 1]; end 
if nargin <= 2, angle= [90 90 90] * degree; end 
sym = findsymmetry(name);

s.name = name;
s.laue = sym.Laue;
s.axis = calcAxis(sym.System,argin_check(axis,'double'),...
  argin_check(angle,'double'));
s.quat = calcQuat(s.laue,s.axis);

superiorto('quaternion','SO3Grid');
s = class(s,'symmetry');
