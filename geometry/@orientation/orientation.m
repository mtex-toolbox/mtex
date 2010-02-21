function o = orientation(varargin)
% defines an orientation
%
%% Syntax
%  ori = orientation(rot,cs,ss)
%  ori = orientation('Euler',phi1,Phi,phi2,cs,ss)
%  ori = orientation('Euler',alpha,beta,gamma,'ZYZ',cs,ss)
%  ori = orientation('Miller',[h k l],[u v w],cs,ss)
%  ori = orientation(name,cs,ss)
%  ori = orientation('axis,v,'angle',omega,cs,ss)
%  ori = orientation('matrix',A,cs)
%  ori = orientation('map',u1,v1,u2,v2,cs)
%  ori = orientation('quaternion',a,b,c,d,cs)
%
%% Input
%  rot       - @rotation
%  cs, ss    - @symmetry
%  u1,u2     - @Miller
%  v, v1, v2 - @vector3d
%  name      - {'brass','goss','cube'}
%
%% Ouptut
%  ori - @orientation
%
%% See also
% quaternion_index orientation_index


% empty quaternion;
rot = rotation;

%% empty constructor
if nargin == 0
  
  o.CS = symmetry;
  o.SS = symmetry;
    
%% copy constructor
elseif isa(varargin{1},'orientation')
        
  o = varargin{1};
  return;

%% determine crystal and specimen symmetry
else
  
  args  = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));

  if length(args) >= 1
    o.CS = varargin{args(1)};
  else
    o.CS = symmetry;
  end

  if length(args) >= 2
    o.SS = varargin{args(2)};
  else
    o.SS = symmetry;
  end
  
  if check_option(varargin,'Miller')
    
    args = find_option(varargin,'Miller');
    
    rot = rotation(Miller2quat(varargin{args+1},varargin{args+2},o.CS));
  
  elseif isa(varargin{1},'char') && exist([varargin{1},'Orientation'],'file')
    
    o = eval([varargin{1},'Orientation(o.CS,o.SS)']);
    return
    
  else
    args  = ~cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true);
    
    rot = rotation(varargin{args});
    
  end
  
end

superiorto('quaternion','rotation','symmetry');
o = class(o,'orientation',rot);
