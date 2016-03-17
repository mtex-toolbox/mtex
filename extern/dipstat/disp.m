function disp(varargin)

global prevCharCnt;

%  Make safe for fprintf, replace control charachters
%s = strrep(s,'%','%%');
%s = strrep(s,'\','\\');

%s = [s '\n'];
fprintf(repmat('\b',1, prevCharCnt));

builtin('disp',varargin{:});

prevCharCnt = 0;

end