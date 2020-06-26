function h = text(m,varargin)
% plot Miller indece
%
% Input
%  m  - Miller
%
% Options
%  symmetrised - plot symmetrically equivalent directions
%  antipodal   - include antipodal symmetry
%  labeled     - plot Miller indice as label
%  label       - plot user label
%
% See also
% vector3d/text

% symmetrise
if check_option(varargin,'symmetrised') && ~check_option(varargin,'skipSymmetrise')

  [m,l] = symmetrise(m,varargin{:},'unique','noAntipodal');
  
  % symmetrise labels
  if ~check_option(varargin,'labeled') && ~isempty(varargin)
    strings = ensurecell(varargin{1});
    if iscellstr(varargin{1}) && ~isempty(strings)
      
      if numel(strings)==1
        strings = repcell(strings{1},length(m),1);
      else
        strings = strings(repelem(1:numel(strings),l));
      end
      varargin{1} = strings;  
    end  
  end
  
  varargin = [varargin,{'skipSymmetrise','noAntipodal'}];
end

% ensure specific plot options
varargin = [varargin(1),m.CS.plotOptions,varargin(2:end)];

h = text@vector3d(m,varargin{:});

if nargout == 0, clear h; end
