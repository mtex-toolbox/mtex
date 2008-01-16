function m = string2Miller(s)
% converts string to Miller indece

% extract filename
s = s(max([1,1+strfind(s,'/')]):end);

% extract indice
s = regexp(s,'( ?-?\d){3,4}','match');

for i = 1:length(s)
  ss = regexp(char(s{i}),'-?\d','match');
  ss = cellfun(@(x) str2double(x),ss,'UniformOutput',0);
  m(i) = Miller(ss{:});
end
