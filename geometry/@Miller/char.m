function c = char(m,varargin)
% Miller indece to string
%
%% Options
%  NO_SCOPES
%  LATEX

c = cell(numel(m),1);

for i = 1:length(m)
  
  if check_option(m,{'uvw','directions'}) || ...
      check_option(varargin,{'uvw','directions'})
    
    h = v2d(subsref(m,i));
    
    if check_option(varargin,{'tex','latex'})
      leftBracket = '\left\langle ';
      rightBracket = '\right\rangle';
    else
      leftBracket = '<';
      rightBracket = '>';
    end
    
  else
    
    h = v2m(subsref(m,i),varargin{:});
    if check_option(varargin,{'tex','latex'})
      leftBracket = '\{';
      rightBracket = '\}';
    else
      leftBracket = '{';
      rightBracket = '}';
    end
    
    if all(round(h)==h)
      s = barchar(h,varargin{:});
    else
      s = '---';
    end
    
    if ~check_option(varargin,'NO_SCOPES')
      s = ['\{',s,'\}']; %#ok<AGROW>
    end
  end
  
  s = [leftBracket barchar(h,varargin{:}) rightBracket];
  if check_option(varargin,'LaTeX')
    s = ['$' s '$'];
  end
  
  c{i} = s;
end

if ~check_option(varargin,'cell')
  c = strcat(c{:});
end


function s=barchar(i,varargin)

comma = check_option(varargin,'commasep');
i = round(i);
s = '';
for j = 1:length(i)
  if (i(j)<0) && check_option(varargin,'latex')
    s = [s,'\bar{',int2str(-i(j)),'}']; %#ok<AGROW>
  else
    s = [s,int2str(i(j))]; %#ok<AGROW>
  end
  
  if comma && j < length(i)
    s = [s,','];
  end
end


function [l,r] = localBrackets(b,varargin)

l = b(1); r = b(2);
if check_option(varargin,{'tex','latex'})
  l = ['\' l]; r = ['\' r];
end








