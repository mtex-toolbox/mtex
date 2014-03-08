function scatter(m,varargin)
% plot Miller indece
%
% Input
%  m  - Miller
%
% Options
%  antipodal   - include antipodal symmetry
%  labeled     - plot Miller indice as label
%  label       - plot user label
%  symmetrised - plot all symmetrically equivalent directions
%  fundamentalRegion - restrict plot the fundamental region
%
% See also
% vector3d/scatter

% symmetrise if needed
if check_option(varargin,'symmetrised') && ~check_option(varargin,'skipSymmetrise')
  
  % first dimension cs - second dimension m
  m = symmetrise(m,varargin{:});
  
  % restrict to fundamental region
  varargin = [varargin,{'removeAntipodal','skipSymmetrise'}];

  % symmetrise data
  if numel(varargin) > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1})
    varargin{1} = repmat(varargin{1}(:)',size(m,1),1);
  end
  
end

% plot them all with the same color
scatter@vector3d(m,varargin{:});
