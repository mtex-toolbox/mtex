function c = char(v,varargin)
% convert to char
%
% A direction given in a crystal frame is written in its Miller indices. A
% point group makes them stand for the whole symmetrically equivalent set,
% so they are written in the family brackets - {hkl} and <uvw> - while the
% trivial group leaves one plane or one direction, (hkl) and [uvw].
%
% Flags
%  LATEX -
%  no_scopes -
%  commasep -
%  hkl, hkil, uvw, UVTW - the convention to write the indices in
%

% a crystal direction is written in indices
if isCrystalDirection(v), c = indexChar(v,varargin{:}); return; end

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

end

% -----------------------------------------------------------------

function c = indexChar(m,varargin)

c = cell(length(m),1);

% output format
format = get_flag(varargin,{'hkl','hkil','uvw','UVTW'});
if ~isempty(format), m.dispStyle = format; end

isFamily = ~isempty(m.CS) && m.CS.id ~= 1;

[leftBracket, rightBracket] = brackets(MillerConvention(m.dispStyle),isFamily,varargin{:});

abc = m.coordinates;
% prevent bar{0}
abc(abs(abc)<1e-8) = 0;

for i = 1:length(m)

  % only display rounded results
  if m.dispStyle == MillerConvention.xyz
    s = xnum2str(abc(i,:),'precision',0.1);
  else
    s = indexBarChar(abc(i,:),varargin{:});
  end

  % add scopes
  if ~check_option(varargin,'NO_SCOPES'), s = [leftBracket s rightBracket]; end %#ok<AGROW>
  if check_option(varargin,'LaTeX'), s = ['$' s '$']; end %#ok<AGROW>

  c{i} = s;
end

if ~check_option(varargin,'cell'), c = strcat(c{:});end

end

% -----------------------------------------------------------------

function s = indexBarChar(i,varargin)

comma = check_option(varargin,'commasep');
space = check_option(varargin,'spacesep');

s = '';
for j = 1:length(i)
  if (i(j)<0) && check_option(varargin,'latex')
    s = [s,'\bar{',xnum2str(-i(j),'precision',1),'}']; %#ok<AGROW>
  elseif i(j) < 0 && getMTEXpref('UTF8Output')  && ~check_option(varargin,'noUTF8')
    ss = xnum2str(-i(j),'precision',1);
    ss = regexprep(ss, '(.)', ['$1' char(hex2dec('0305'))]);
    s = [s,ss]; %#ok<AGROW>
  else
    s = [s,xnum2str(i(j),'precision',1)]; %#ok<AGROW>
  end

  if comma && j < length(i)
    s = [s,','];
  elseif space && j < length(i)
    s = [s,' '];
    if i(j+1)>=0, s = [s,' ']; end
  elseif (any(i>9) || any(abs(i-round(i))>1e-3)) && j<length(i)
    s = [s,' '];
  end
end

end

% -----------------------------------------------------------------

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

end

% -----------------------------------------------------------------

function s=barchar(i,varargin)

if i<0 && check_option(varargin,'latex')
  s = ['\bar{',int2str(-i),'}'];
else
  s = int2str(i);
end

end
