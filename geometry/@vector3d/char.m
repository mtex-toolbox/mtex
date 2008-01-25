function c = char(v,varargin)
% convert to char
%% Options
%  LATEX

if max(abs(v.x)) < 1e-14, v.x = zeros(size(v.x));end
if max(abs(v.y)) < 1e-14, v.y = zeros(size(v.y));end
if max(abs(v.z)) < 1e-14, v.z = zeros(size(v.z));end

c = [];
for i = 1:length(v.x)
  if check_option(varargin,'LATEX')
    iv = vec2int([v(i).x,v(i).y,v(i).z]);
    if ~isempty(iv)
      c = [c,'(',barchar(iv(1)),barchar(iv(2)),barchar(iv(3)),')'];
    end
  else
    c = [c,'(',num2str(v.x(i)),',',num2str(v.y(i)),',',num2str(v.z(i)),')']; %#ok<AGROW>
  end
end

dm = findstr(c,'$$');
c([dm,dm+1]) = [];

function iv = vec2int(v)

% find common divisor
nz = find(abs(v)==max(abs(v)),1,'first');

for i = 1:9
  iv = v / v(nz) * i;
  e(i) = sum(abs(iv-round(iv)));
end

j = find(e<10e-2,1,'first');

if ~isempty(j)
  iv = round(v / abs(v(nz)) * j);
else
  iv = [];
end

  

function s=barchar(i)

if i<0
		s = ['$\bar{',int2str(-i),'}$'];
else
		s = int2str(i);
end
