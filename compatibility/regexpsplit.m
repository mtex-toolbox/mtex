function str = regexpsplit(varargin)
% mimics regexp(a,b,'split') as introduced in MATLAB version 


[a,b] = regexp(varargin{:});

a = [a-1,length(varargin{1})];
b = [1,b+1];

str = arrayfun(@(i) varargin{1}(b(i):a(i)),1:length(a),'uniformoutput',0);
ind = cellfun('isempty',str);
str(ind) = {''};
% if any(ind),  str{ind} = ''; end