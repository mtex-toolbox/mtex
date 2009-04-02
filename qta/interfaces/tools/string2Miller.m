function [m,r] = string2Miller(s)
% converts string to Miller indece

% default value
m = Miller(1,0,0);

% extract filename
s = s(max([1,1+strfind(s,'/')]):end);

% first try to extract 4 Miller indice
e = regexp(fliplr(s),'([0123456]-? ?){4}','match');
r = ~isempty(e);

ok = 1;
for i = 1:length(e)
  ss = regexp(fliplr(char(e{i})),'-?\d','match');
  ss = cellfun(@(x) str2double(x),ss,'UniformOutput',0);
  [m(i),er] = Miller(ss{:});
  ok = ok & ~er;
end
m = fliplr(m);
if ~isempty(e) && ok, return;end

% if this fails try to extract only 3 Miller indice

  e = regexp(fliplr(s),'([0123456] ?){3}','match');
  r = ~isempty(e);

  for i = 1:length(e)
    ss = regexp(fliplr(char(e{i})),'-?\d','match');
    ss = cellfun(@(x) str2double(x),ss,'UniformOutput',0);
    m(i) = Miller(ss{:});
  end
end


