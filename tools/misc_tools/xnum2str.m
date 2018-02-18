function s = xnum2str(n,m,width)
% convert number to string
%
% Syntax
%   s = xnum2str(n)
%
% Input
%  n - double | int
%  m - precission
%
% Output
% s - string

if nargin == 1 || isempty(m), m = n;end
if length(n) > 1
  s = num2str(n(1));
  for i = 2:length(n)
    s = [s,' ',num2str(n(i))];
  end
  return;
elseif isempty(n)
  n = 0;
end

%check whether to use floating point or not
if abs(m)>1000000
  s = num2str(n,'%7.2g');
elseif abs(m) >= 10
  s = num2str(n,'%6.0f');
elseif abs(m) >= 1
  s = num2str(n,'%6.1f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(m) > 0.1
  s = num2str(n,'%7.2f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(m) > 0.01
  s = num2str(n,'%7.3f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(m) > 0.001
  s = num2str(n,'%7.4f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(m) > 0.0001
  s = num2str(n,'%7.5f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
else
  s = num2str(n,'%7.2g');
end

% eliminate ending point and meaningles minus
if s(end) == '.', s = s(1:end-1);end
if strcmp(s,'-0'), s = '0';end

if nargin == 3
  s = [repmat(' ',1,max(0,width-length(s))) s];
end