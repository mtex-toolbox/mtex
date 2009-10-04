function s = xnum2str(n)
% convert number to string
%
%% Syntax
%  s = xnum2str(n)
%
%% Input
%  n - double | int
%
%% Output
% s - string

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
if abs(n)>1000000
  s = num2str(n,'%7.2g');
elseif abs(n) >= 10
  s = num2str(n,'%6.0f');
elseif abs(n) >= 1
  s = num2str(n,'%6.1f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(n) > 0.1
  s = num2str(n,'%7.2f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(n) > 0.01
  s = num2str(n,'%7.3f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(n) > 0.001
  s = num2str(n,'%7.4f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
elseif abs(n) > 0.0001
  s = num2str(n,'%7.5f');
  % eliminate ending zero
  s = s(1:find(s~='0',1,'last'));
else
  s = num2str(n,'%7.2g');
end

% eliminate ending point
if s(end) == '.', s = s(1:end-1);end
