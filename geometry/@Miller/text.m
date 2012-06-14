function varargout = text(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL       - plot symmetrically equivalent directions
%  antipodal - include antipodal symmetry
%  labeled   - plot Miller indice as label
%  label     - plot user label
%
%% See also
% vector3d/text

%% preprocess input

% get axis hande
[ax,m,varargin] = getAxHandle(m,varargin{:}); %#ok<ASGLU>

% extract text
strings = ensurecell(varargin{1});

if numel(strings)==1, strings = repcell(strings{1},numel(m),1);end

% symmetrise
if check_option(varargin,{'all','symmetrised'})
  
  [m,l] = symmetrise(m,varargin{:});
  if ~isempty(strings)
    strings = strings(rep(1:numel(strings),l));
  end
  
end
  

if check_option(varargin,'labeled')
  strings = char(m,getpref('mtex','textInterpreter'),'cell');
end

varargin = delete_option(varargin,'labeled');

[varargout{1:nargout}] = text(m.vector3d,strings,varargin{:});
