function c = char(v,varargin)
% convert to char
%
% Flags
%  LATEX - 
%  

% short summary for long vectors
if length(v) > 4
  
  c = [size2str(v), ' points'];
  if ~check_option(varargin,'short') && v.resolution<2*pi
    c = [c, ', res.: ',xnum2str(v.resolution * 180/pi),mtexdegchar];
  end
  
  return
end

% list all elements 

if max(abs(v.x)) < 1e-14, v.x = zeros(size(v.x));end
if max(abs(v.y)) < 1e-14, v.y = zeros(size(v.y));end
if max(abs(v.z)) < 1e-14, v.z = zeros(size(v.z));end

c = [];
for i = 1:length(v.x)
  if check_option(varargin,{'LATEX','tex'})
    if v == xvector
      c = [c,' x'];
    elseif v == yvector
        c = [c,' y'];
    elseif v == zvector
      c = [c,' z'];
    else
      iv = vec2int([v.x(i),v.y(i),v.z(i)]);
      if ~isempty(iv)
        c = [c,' ',barchar(iv(1),varargin{:}),...
          barchar(iv(2),varargin{:}),...
          barchar(iv(3),varargin{:})];
      else
        c = [c,' ',num2str([v.x(i),v.y(i),v.z(i)],'(%3.2f,%3.2f,%3.2f)')];
      end
    end
  else
    c = [c,' ',num2str(v.x(i)),',',num2str(v.y(i)),',',num2str(v.z(i))]; %#ok<AGROW>
  end
end

if ~isempty(c), c(1)=[];end
if ~isempty(c) && check_option(varargin,{'LaTeX'}), c = ['$' c '$'];end

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


function s=barchar(i,varargin)

if i<0 && check_option(varargin,'latex')
  s = ['\bar{',int2str(-i),'}'];
else
  s = int2str(i);
end
