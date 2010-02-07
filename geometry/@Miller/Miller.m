function [m,er] = Miller(varargin)
% define a crystal direction by Miller indice
%
%% Syntax
%
%
%% Input
%  h,k,l,n(optional) - double
%  CS - crystal @symmetry
%
%

er = 0;

% check for symmetry
if nargin > 0 && isa(varargin{nargin},'symmetry')
  m.CS = varargin{nargin};
  varargin = varargin(1:end-1);
else
  m.CS = symmetry;
end

if nargin == 0
  
  v = vector3d;

elseif isa(varargin{1},'Miller')
  
  m = varargin{1};
  return
  
elseif isa(varargin{1},'vector3d')
  
  v = varargin{1};
  
elseif isa(varargin{1},'double')
  
  for i = 2:length(varargin), argin_check(varargin{i},'double'); end
  
  if length(varargin) > 4 || length(varargin) < 3
    error('wrong number of arguments!');
  end
  
  v = m2v(varargin{1},varargin{2},varargin{end},m.CS);
  if length(varargin)==4 && varargin{1} + varargin{2} + varargin{3} ~= 0
    if nargout == 2
      er = 1;
    else
      warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-varargin{1} + varargin{2})]); %#ok<WNTAG>
    end
  end
end

superiorto('vector3d');
m = class(m,'Miller',v);

