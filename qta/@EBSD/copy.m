function ebsd = copy(ebsd,varargin)
% copy selected points from EBSD data
%
%% Syntax  
% ebsd  = copy(ebsd,condition)
% ebsd  = copy(ebsd,get(ebsd,'phase')~=1)
%
%% Input
%  ebsd      - @EBSD
%  condition - index set 
%
%% Output
%  ebsd - @EBSD
%
%% See also
% EBSD/get EBSD/copy EBSD_index

if nargin == 1, return;end

smpsz = sampleSize(ebsd);
cs = cumsum([0,smpsz]);

%% if integer indexing convert to logical indexing
if isa(varargin{1},'double'),  
  x = zeros(1,cs(end));
  x(varargin{1}) = 1;
  varargin{1} = logical(x);
end

%% logical indexing
if isa(varargin{1},'logical')
  
  % for each phase
  for i=1:length(ebsd)
    idi = condition(cs(i)+1:cs(i+1));
    
    % filter spatial coordinates
    if ~isempty(ebsd(i).X)
      ebsd(i).X = ebsd(i).X(idi,:);
    end

    % filter properties
    ebsd_fields = fields(ebsd(i).options);
    for f = 1:length(ebsd_fields)
      if numel(ebsd(i).options.(ebsd_fields{f})) == smpsz(i)
        ebsd(i).options.(ebsd_fields{f}) = ebsd(i).options.(ebsd_fields{f})(idi,:);
      end
    end
  
    % filter orientations
    ebsd(i).orientations = ebsd(i).orientations(idi);
  end
end

%% filter by phase

varargin = delete_option(varargin,'property',1);

if check_option(varargin,'phase')
  
  phase = get_option(varargin,'phase');

  % filter by phase number
  if isa(phase,'double')
    
    % find matching phases
    match = ismember([ebsd.phase],phase);

  % filter by mineral name
  elseif isa(phase,'char') || isa(phase,'cell')
    
    % extract mineral names
    [CS{1:numel(ebsd)}] = get(ebsd,'CS');
    phases = cellfun(@(cs) get(cs,'mineral'),CS,'uniformOutput',false);
    
    % compare to given phase
    match = cellfun(@(str) any(strcmpi(phase,str)),phases);

  end
  
  % restrict to found phases
  ebsd = ebsd(match);
  
end

%% filter by region
if check_option(varargin,'region')
  region = get_option(varargin,'region');
  if isa(region,'double')
    region = polygon([region(1) region(2);region(3) region(2);...
      region(3) region(4); region(1) region(4); region(1) region(2)]);
  end
  
  ebsd = inpolygon(ebsd,region);
end
