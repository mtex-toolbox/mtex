function varargout = scatter(m,varargin)
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
  
  % restrict to fundamental region
  %varargin = [varargin,{'removeAntipodal','skipSymmetrise'}];
  varargin = [varargin,{'skipSymmetrise'}]; % we do not need to symmtrise twice
  % the option 'removeAntipodal' is used in symmetrise below as antipodal
  % symmetry is treaded seperately by the plot command
  
  % symmetrise data with repetition
  if numel(varargin) > 0 && isnumeric(varargin{1}) && ~isempty(varargin{1});
  
    % first dimension cs - second dimension m
    m = symmetrise(m,'removeAntipodal',varargin{:});
    
    varargin{1} = repmat(varargin{1}(:)',size(m,1),1);    
      
  elseif length(m) < 100 || check_option(varargin,{'labeled','label'}) 
  
      [m,l] = symmetrise(m,'removeAntipodal',varargin{:}); % symmetrise without repetition
        
  else 
    
    m = symmetrise(m,'removeAntipodal',varargin{:}); % symmetrise with repetition
    
  end
  
end

% plot them all with the same color
[varargout{1:nargout}] = scatter@vector3d(m,varargin{:});
