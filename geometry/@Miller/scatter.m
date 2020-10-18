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
      
  % symmetrise data with repetition
  if numel(varargin) > 0 && ~isempty(varargin{1}) && ...
      (isnumeric(varargin{1}) || isa(varargin{1},'crystalShape'))
  
    % first dimension cs - second dimension m
    m = symmetrise(m,varargin{:});
    
    varargin{1} = repmat(varargin{1}(:)',size(m,1),1);
    
    varargin = replicateMarkerSize(varargin,size(m,1));
            
  elseif length(m) < 100 || check_option(varargin,{'labeled','label'}) 
    
    % plot only unqiue points
    [m,l] = symmetrise(m,'unique','noAntipodal',varargin{:}); % symmetrise without repetition
    
    if check_option(varargin,'label')
      label = ensurecell(get_option(varargin,'label'));
      label = repelem(label,l);
      varargin = set_option(varargin,'label',label);
    end
      
  else 
    
    m = symmetrise(m,varargin{:}); % symmetrise with repetition
    varargin = replicateMarkerSize(varargin,size(m,1));
    
  end  
  
  % we do not need to symmtrise twice
  varargin = [varargin,{'skipSymmetrise','noAntipodal'}]; 
end

if numel(varargin) > 0 && (isnumeric(varargin{1}) || isa(varargin{1},'crystalShape'))
  varargin = [varargin(1),m.CS.plotOptions,varargin(2:end)];
else
  varargin = [m.CS.plotOptions,varargin];
end

% plot them all with the same color
[varargout{1:nargout}] = scatter@vector3d(m,varargin{:},m.CS);

end

function opt = replicateMarkerSize(opt,n)

ms = get_option(opt,'MarkerSize');
if length(ms)>1 && n > 1
  ms = repmat(ms(:).',n,1);
  opt = set_option(opt,'MarkerSize',ms);
end
  
end