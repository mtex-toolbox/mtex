function c = char(m,varargin)
% Miller indece to string
%
%% Options
%  NO_SCOPES
%  LATEX

c = [];

for i = 1:length(m)

  if check_option(m,{'uvw','directions'}) || check_option(varargin,{'uvw','directions'})
  
    uvtw = v2d(subsref(m,i));

    s = ['[',barchar(uvtw,varargin{:}),']'];

  else
    
    hkl = v2m(subsref(m,i),varargin{:});
    
    if all(round(hkl)==hkl)
      s = barchar(hkl,varargin{:});
    else
      s = '---';
    end
    
    if ~check_option(varargin,'NO_SCOPES')
      s = ['(',s,')']; %#ok<AGROW>
    end    
  end

  c = strcat(c,s);
end


function s=barchar(i,varargin)

s = '';
for j = 1:length(i)
  if (i(j)<0) && check_option(varargin,'latex')
		s = [s,'\bar{',int2str(-i(j)),'}']; %#ok<AGROW>
  else
    s = [s,int2str(i(j))]; %#ok<AGROW>
  end
end
