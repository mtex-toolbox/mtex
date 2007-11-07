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
    c = [c,'(',barchar(v(i).x),barchar(v(i).y),barchar(v(i).z),')'];
  else
    c = [c,'(',num2str(v.x(i)),',',num2str(v.y(i)),',',num2str(v.z(i)),')']; %#ok<AGROW>
  end
end

dm = findstr(c,'$$');
c([dm,dm+1]) = [];

function s=barchar(i)

if i<0
		s = ['$\bar{',int2str(-i),'}$'];
else
		s = int2str(i);
end
