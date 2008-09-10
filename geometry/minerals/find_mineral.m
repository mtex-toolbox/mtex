function m = find_mineral(name,mineral_list)

if nargin < 2, load('mineral_list');end

m = [];

for i = 1:length(mineral_list)
  
  if strcmpi(mineral_list{i}.name,name)
    m = mineral_list{i};
    return;
  end
  
end

disp(['Mineral ' name ' not found!']);



