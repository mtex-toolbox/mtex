function grains = copyproperty(grains, ebsd, varargin)
% copy an abitrary property of the corresponding ebsd object
%
%% Syntax
%  grains = copyproperty(grains,ebsd,'property');
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD
%  property - char
%
%% Options
%  METHOD   - function_handle
%
%% Output
%  grains   - @grain
%
%% Example
% grains = copyproperty(grains,ebsd,'all');
% grains = copyproperty(grains,ebsd,'bc',@min);
%


m = find_type(varargin,'function_handle');
if ~isempty(m)
  method = varargin{m};
else
  method = @mean;
end

m1 = find_type(varargin,'char');
m2 = find_type(varargin,'cell');
if isempty(m1) && isempty(m2), property = 'all'; 
else  property = varargin{[m1 m2]};
end

[grains ebsd ids] = link(grains,ebsd);

opts = partition(ebsd,ids,'fields',property);

vname = fieldnames(opts);

for k=1:length(vname)
  if isempty(strfind(vname{k},'grain_id'))
    if isnumeric(opts(end).(vname{k}))      
      grains = set(grains,vname{k}, ...
        cellfun(method,{opts.(vname{k})}));
    else
      grains = set(grains,vname{k}, {opts.(vname{k})});
    end
  end
end
