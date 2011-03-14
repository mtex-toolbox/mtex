function grains = copy(grains,varargin)
% copy selected grains from a list of grains
%
%% Syntax  
% grains = copy(grains,condition)
% grains = copy(grains,get(grains,'phase')~=1)
%
%% Input
%  grains    - @grain
%  condition - index set 
%
%% Output
%  grains - @grain
%
%% See also
% grain/get grain_index

if nargin == 1, return;end


%% if indexing use direct indexing
if isa(varargin{1},'double') || isa(varargin{1},'logical'),   
  grains = grains(varargin{1});
end

%% filter by phase

% remove this duplicated usage of property
varargin = delete_option(varargin,'property',1);

if check_option(varargin,'phase')
  
  phase = get_option(varargin,'phase');

  % filter by phase number
  if isa(phase,'double')
    
    % find matching phases
    match = ismember(get(grains,'phase'),phase);

  % filter by mineral name
  elseif isa(phase,'char') || isa(phase,'cell')
    
    % find all phases
    grainPhases = get(grains,'phase');
    [phases ind] = unique(grainPhases);
    
    % extract mineral names
    CS = get(grains(ind),'CSCell');
    minerals = cellfun(@(cs) get(cs,'mineral'),CS,'uniformOutput',false);
    
    % compare to given phase
    matchingPhases = cellfun(@(str) any(strcmpi(phase,str)),minerals);

    % find matching phases
    match = ismember(grainPhases,phases(matchingPhases));
    
  end
  
  % restrict to found phases
  grains = grains(match);
  
end
