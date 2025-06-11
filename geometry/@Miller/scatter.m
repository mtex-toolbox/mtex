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


% Allow color coding with several colors
mcf = get_option(varargin,'MarkerFaceColor',[]);
if isnumeric(mcf) && ~isempty(mcf)
  if numel(mcf) == length(m)
    mcf = reshape(mcf,[],1);
  elseif numel(mcf)~=3
    mcf = reshape(mcf,[],3);
  end
  varargin = {mcf,varargin{:}};
  varargin = delete_option(varargin,'MarkerFaceColor');
  % varargin = set_option(varargin,'FaceVertexCdata',mcf);
end

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
    
    % plot only unique points
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

% plot them all with the same color
[varargout{1:nargout}] = scatter@vector3d(m,varargin{:},m.CS,m.CS.how2plot);

end

function opt = replicateMarkerSize(opt,n)

ms = get_option(opt,'MarkerSize');
if length(ms)>1 && n > 1
  ms = repmat(ms(:).',n,1);
  opt = set_option(opt,'MarkerSize',ms);
end
  
end