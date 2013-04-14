function o = orientation(varargin)
% defines an orientation
%
%% Syntax
%  ori = orientation(rot,cs,ss) -
%  ori = orientation('Euler',phi1,Phi,phi2,cs,ss) -
%  ori = orientation('Euler',alpha,beta,gamma,'ZYZ',cs,ss) -
%  ori = orientation('Miller',[h k l],[u v w],cs,ss) -
%  ori = orientation(name,cs,ss) -
%  ori = orientation('axis,v,'angle',omega,cs,ss) -
%  ori = orientation('matrix',A,cs) -
%  ori = orientation('map',u1,v1,u2,v2,cs) -
%  ori = orientation('quaternion',a,b,c,d,cs) -
%
%% Input
% rot       - @rotation
% cs, ss    - @symmetry
% u1,u2     - @Miller
% v, v1, v2 - @vector3d
% name      - named orientation
%    currently available:
%
%    * 'Cube', 'CubeND22', 'CubeND45', 'CubeRD'
%    * 'Goss', 'invGoss'
%    * 'Copper', 'Copper2'
%    * 'SR', 'SR2', 'SR3', 'SR4'
%    * 'Brass', 'Brass2'
%    * 'PLage', 'PLage2', 'QLage', 'QLage2', 'QLage3', 'QLage4'
%
%% Ouptut
%  ori - @orientation
%
%% See also
% quaternion_index orientation_index




%% empty constructor
if nargin == 0

  o.CS = symmetry;
  o.SS = symmetry;
    
  rot = rotation;

%% copy constructor
elseif isa(varargin{1},'orientation')

  o = varargin{1};
  if nargin > 1 && isa(varargin{2},'symmetry')
    o.CS = varargin{2};
    if nargin > 2 && isa(varargin{3},'symmetry')
      o.SS = varargin{3};
    end
  end
  return;

elseif isa(varargin{1},'quaternion') && ~isa(varargin{1},'symmetry')
  
  rot = rotation(varargin{1});
  if nargin >= 2 
    o.CS = varargin{2};
  else
    o.CS = symmetry;
  end
  
  if nargin >= 3
    o.SS = varargin{3};
  else
    o.SS = symmetry;
  end
  
%% determine crystal and specimen symmetry
else

  args  = cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true);

  if sum(args) >= 1
    o.CS = varargin{find(args,1)};
  else
    o.CS = symmetry;
  end

  if sum(args) >= 2
    o.SS = varargin{find(args,1,'last')};
  else
    o.SS = symmetry;
  end

  if check_option(varargin,'Miller')

    args = find_option(varargin,'Miller');

    rot = rotation(Miller2quat(varargin{args+1},varargin{args+2},o.CS));

  elseif isa(varargin{1},'char')

    % some predefined orientations
    orientationList = {
      {'Cube',0,0,0},...
      {'CubeND22',22,0,0},...
      {'CubeND45',45,0,0},...
      {'CubeRD',0,22,0},...
      {'Goss',0,45,0},...
      {'Copper',90,30,45},...
      {'Copper2',270,30,45},...
      {'SR',53,35,63},...
      {'SR2',233,35,63},...
      {'SR3',307,35,27},...
      {'SR4',127,35,27},...
      {'Brass',35,45,0},...
      {'Brass2',325,45,0},...
      {'PLage',65,45,0},...
      {'PLage2',295,45,0},...
      {'QLage',65,20,0},...
      {'QLage2',245,20,0},...
      {'QLage3',115,160,0},...
      {'QLage4',295,160,0},...
      {'invGoss',90,45,0}};

    found = cellfun(@(x) strcmpi(x{1},varargin{1}),orientationList);
  
    if any(found)
    
      rot = rotation('Euler',orientationList{found}{2}*degree,...
        orientationList{found}{3}*degree,...
        orientationList{found}{4}*degree,'Bunge');
      
    elseif exist([varargin{1},'Orientation'],'file') 
      % there is a file defining this specific orientation

      o = eval([varargin{1},'Orientation(o.CS,o.SS)']);
      return

    else % define as rotation
      
      rot = rotation(varargin{~args});
        
    end

  else % define as rotation
    args  = ~cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true);

    rot = rotation(varargin{args});

  end

end

superiorto('quaternion','rotation','symmetry');
o = class(o,'orientation',rot);
