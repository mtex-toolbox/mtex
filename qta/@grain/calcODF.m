function grains = calcODF(grains,ebsd,varargin)
% bypass-function to calculate individual ODFs for each grain or an ODF based on the orientation of each grain
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD, specifiy to perform an ODF estimation based on original data
%
%% Output
%  grains  - @grain with odf as property
%  or odf  - @ODF if based on orientation of grains
%
%% Options
%  phase   - specifies the phase to calculate the odf for
%
%% See also
% EBSD/calcODF

if nargin>1 && isa(ebsd,'EBSD')
  vdisp('------ MTEX -- single grain to ODF computation-----------',varargin{:})
  
  [ebsd grains]= link(ebsd,grains);
  [phase uphase] = get(grains,'phase');
  
  
  for k=1:length(uphase)
    
    vdisp(['density estimation for grains of phase ' num2str(uphase(k)) ],varargin{:}) 
    
    [kernel hw options] = extract_kernel(get(ebsd(k),'orientations'),varargin{:});
    
    vdisp([' kernel: ' char(kernel)],varargin{:});
    if ~check_option(varargin,'exact'), 
      [S3G options]= extract_SO3grid(ebsd(k),options);
    end
    
    ndx = phase == uphase(k);
    [o grains( ndx )] = ...
        grainfun(@calcODF,grains(ndx),ebsd(k),'property',get_option(varargin,'property','ODF'),...
        options{:},'silent');
    
  end

else
  if nargin>1, varargin = [{ebsd} varargin]; end
  [phase uphase] = get(grains,'phase');
  if length(uphase) > 1
    warning('MTEX:MultiplePhases','This operatorion is only permitted for a single phase! I''m going to process only the first phase.'); end
  
  o = get(grains(phase == uphase(1)),'orientation');  
  grains = calcODF( EBSD( o ) ,varargin{:});
end

