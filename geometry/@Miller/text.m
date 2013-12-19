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
[ax,m,varargin] = getAxHandle(m,varargin{:});

% extract text
strings = ensurecell(varargin{1});

if numel(strings)==1, strings = repcell(strings{1},numel(m),1);end

% symmetrise
if check_option(varargin,{'all','symmetrised','fundamentalRegion'})

  if ~isempty(ax) && isappdata(ax{:},'projection')
    p = getappdata(ax{:},'projection');
    if p.antipodal, varargin = [varargin,{'antipodal'}];end
  end
  if check_option(m,'antipodal')
    varargin = [varargin,{'antipodal'}];
  end

  [m,l] = symmetrise(m,varargin{:},'keepAntipodal');
  if ~isempty(strings)
    strings = strings(rep(1:numel(strings),l));
  end
  varargin = [varargin,{'removeAntipodal'}];

end


if check_option(varargin,'labeled')
  strings = char(m,getMTEXpref('textInterpreter'),'cell');
end

varargin = delete_option(varargin,'labeled');

[varargout{1:nargout}] = text(ax{:},m.vector3d,strings,varargin{:});
