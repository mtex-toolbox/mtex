function c = char(v,varargin)
% Miller indece to string
%% Options
%  NO_SCOPES
%  LATEX

c = [];

for i = 1:length(v)
  
  if any(strcmp(Laue(v(i).CS),{'-3','-3m','6/m','6/mmm'}))
    s = [barchar(v(i).h,varargin{:}),barchar(v(i).k,varargin{:}),...
      barchar(-v(i).h-v(i).k,varargin{:}),barchar(v(i).l,varargin{:})];
  else
    s= [barchar(v(i).h,varargin{:}),barchar(v(i).k,...
      varargin{:}),barchar(v(i).l,varargin{:})];
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
