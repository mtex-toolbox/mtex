function [m,er] = Miller(varargin)
% define a crystal direction by Miller indice
%
%% Syntax
% m = Miller(h,k,l,cs)
% m = Miller(h,k,l,cs,'hkl')
% m = Miller(h,k,l,cs,'pole')
% m = Miller(h,k,i,l,cs)
% m = Miller(u,v,w,cs,'uvw')
% m = Miller(u,v,t,w,cs,'uvw')
% m = Miller(u,v,w,cs,'direction')
% m = Miller(x,cs)
%
%% Input
%  h,k,l,i(optional) - Miller indice of the plane normal
%  u,v,w,t(optional) - Miller indice of a direction
%  x  - @vector3d
%  cs - crystal @symmetry
%
%% See also
% vector3d_index symmetry_index

er = 0;

%% check for symmetry
m.CS = getClass(varargin,'symmetry',symmetry);

%% empty
if nargin == 0
  
  v = vector3d;

%% copy constructor
elseif isa(varargin{1},'Miller')
  
  m = varargin{1};
  return
  
%% vector3d  
elseif isa(varargin{1},'vector3d')
  
  if any(norm(varargin{1})) == 0
    error('(0,0,0) is not a valid Miller index');
  end
  
  v = varargin{1};
  
%% hkl and uvw  
elseif isa(varargin{1},'double')
  
  % get hkls and uvw from input
  nparam = min([length(varargin),4,find(cellfun(@(x) ~isa(x,'double'),varargin),1)-1]);
  
  % check for right input
  if nparam < 3, error('You need at least 3 Miller indice!');end
  
  % check fourth coefficient is right
  if nparam==4 && varargin{1} + varargin{2} + varargin{3} ~= 0
    if nargout == 2
      er = 1;
    elseif check_option(varargin,{'uvw','uvtw','direction'})
      warning(['Convention u+v+t=0 violated! I assume t = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
    else
      warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
    end
  end
  
  if check_option(varargin,{'uvw','uvtw','direction'});
    
    if nparam==4
      varargin{1} = varargin{1} - varargin{3};
      varargin{2} = varargin{2} - varargin{3};
    end
    v = d2v(varargin{1},varargin{2},varargin{nparam},m.CS);
    v = set_option(v,'uvw');
    
  else    
    
    v = m2v(varargin{1},varargin{2},varargin{nparam},m.CS);
  
  end  
    
end

v = set_option(v,...
  extract_option(varargin,{'north','south','antipodal'}));

superiorto('vector3d');
m = class(m,'Miller',v);
