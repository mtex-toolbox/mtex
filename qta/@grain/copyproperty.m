function grains = copyproperty(grains, ebsd, f)
% copy an abitrary property of the corresponding ebsd object
%
%% Syntax
%  grains = copyproperty(grains,ebsd,function_handle);
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD
%
%% Options
%  METHOD   - function_handle
%
%% Output
%  grains   - @grain
%
%% Example
% grains = copyproperty(grains,ebsd);
% grains = copyproperty(grains,ebsd,@min);
%


if nargin > 2
  method = f;
else
  method = @(x)sum(x)./numel(x);
end

[grains ebsd ids] = link(grains,ebsd);

opts = partition(ebsd,ids,'fields');
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
