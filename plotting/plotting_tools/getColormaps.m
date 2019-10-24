function [cm,cmd] = getColormaps

fnd = dir([mtex_path filesep 'plotting' filesep 'colormaps' filesep '*ColorMap.m']);

% remove extension to create command
cmd = cellfun(@(x) x(1:end-2),{fnd.name},'UniformOutput',false);

% remove ColorMap
cm = cellfun(@(x) x(1:end-8),cmd,'UniformOutput',false);

end