function c = char(m,varargin)
% Miller indece to string
%
%% Options
%  NO_SCOPES
%  LATEX

[h,k,l] = v2m(m);

c = [];

for i = 1:length(m)
  
  if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
    
    s = [barchar(h(i),varargin{:}),barchar(k(i),varargin{:}),...
      barchar(-h(i)-k(i),varargin{:}),barchar(l(i),varargin{:})];
    
  else
    
    s= [barchar(h(i),varargin{:}),barchar(k(i),...
      varargin{:}),barchar(l(i),varargin{:})];
  end
  
  if check_option(varargin, {'TEX','LATEX'})
    s = ['\{',s,'\}'];
  elseif ~check_option(varargin,'NO_SCOPES')
    s = ['{',s,'}'];
  end
    
  c = strcat(c,s);
end


function s=barchar(i,varargin)

if (i<0) && check_option(varargin,'latex')
		s = ['\bar{',int2str(-i),'}'];
else
		s = int2str(i);
end
