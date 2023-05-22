function s = xnum2str(n,varargin)
% convert number to string
%
% Syntax
%   s = xnum2str(n)
%   s = xnum2str(n,'cell')
%   s = xnum2str(n,'precision',2)
%   s = xnum2str(n,'fixedWidth',5)
%   s = xnum2str(n,'delimiter',', ')
%
% Input
%  n - double | int
%
% Output
%  s - string
%

% get precision parameter
if imag(n)~=0
  pre = min(abs(real(n)),abs(imag(n)));
else
  pre = n;
end
m = get_option(varargin,'precision',pre);

% handle arrays componentwise
if length(n) > 1
 
  del = get_option(varargin,'delimiter',' ');
  s = arrayfun(@(v) xnum2str(v,varargin{:}),n,'UniformOutput',false);
  
  if ~check_option(varargin,'cell')
    s = [s(:).';repcell(del,1,length(s))];
    s = [s{1:end-1}];
  end
    
  return;
elseif isempty(n)
  n = 0;
end

% seperate real and imaginary part
if isnan(n)
  s = 'NaN';
  return
elseif abs(imag(n))<=0.01*abs(real(n))
  n = real(n);
elseif abs(real(n))<0.01*abs(imag(n))
  s = [xnum2str(imag(n),varargin),'i'];
  return
else
  if imag(n)>0
    vz='+';
  else 
    vz='';
  end
  s = [xnum2str(real(n),'precision',m,varargin),vz,xnum2str(imag(n),'precision',m,varargin),'i'];
  return
end

% check whether to use floating point or not
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

% add spaces if needed
if check_option(varargin,'fixedWidth')
  width = get_option(varargin,'fixedWidth');
  s = [repmat(' ',1,max(0,width-length(s))) s];
end