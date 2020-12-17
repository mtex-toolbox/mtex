function c = char(m,varargin)
% Miller indece to string
%
% Flags
%  no_scopes - 
%  latex - 
%  commasep - 

c = cell(length(m),1);

% output format
format = get_flag(varargin,{'hkl','hkil','uvw','UVTW'});
if ~isempty(format), m.dispStyle = format; end


[leftBracket, rightBracket] = brackets(MillerConvention(m.dispStyle));

abc = m.coordinates;

for i = 1:length(m)
  
  % only display rounded results
  if m.dispStyle == MillerConvention.xyz
    s = xnum2str(abc(i,:),'precision',0.1);
  else
    s = barchar(abc(i,:),varargin{:});
  end
  
  % add scopes
  if ~check_option(varargin,'NO_SCOPES'), s = [leftBracket s rightBracket]; end %#ok<AGROW>
  if check_option(varargin,'LaTeX'), s = ['$' s '$']; end %#ok<AGROW>
  
  c{i} = s;
end

if ~check_option(varargin,'cell'), c = strcat(c{:});end

% -----------------------------------------------------------------

function s=barchar(i,varargin)

comma = check_option(varargin,'commasep');
space = check_option(varargin,'spacesep');

s = '';
for j = 1:length(i)
  if (i(j)<0) && check_option(varargin,'latex')
    s = [s,'\bar{',xnum2str(-i(j),'precision',1),'}']; %#ok<AGROW>
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
