function grains = copyproperty(grains, ebsd, property,varargin)
% copy an abitrary property of the corresponding ebsd object
%
%% Input
% grains   - @grain
% ebsd     - @ebsd
% property - char
%
%% Option
% METHOD   - function_handle
%
%% Output
% grains   - @grain
%
%% Example
% grains = copyproperty(grains,ebsd,'phase');
% grains = copyproperty(grains,ebsd,'bc',@min);
%


m = find_type(varargin,'function_handle');
if ~isempty(m)
  method = varargin{m};
else
  method = @mean;
end

[grains ebsd ids] = get(grains,ebsd);

ebsd = partition(ebsd,ids);
p    = get(ebsd,property);

%type check
if ~isnumeric(p), error('must be a numeric value'), end

gl = GridLength(ebsd);

if length(p) == sum(gl)
  p = mat2cell(p,gl,1);
elseif length(p) == length(grains)
  p = mat2cell(p,ones(size(grains)),1);
else
  error('dimensional mismatch')
end

%set the new property
grains = set(grains,property,cellfun(method,p));