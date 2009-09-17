function str = char(pf,varargin)
% standard output

%if isempty(pf(1).comment)
%  str = {};
%else
%  str = pf(1).comment;
%  if length(pf) > 1, str = [str, ', ...'];end
%  str = {str,repmat('-',1,length(str))};
%end

%for i = 1:numel(pf)
%	str = [str,['Miller indice h = ',char(pf(i).h)]]; %#ok<*AGROW>
%  str = [str,['r = ',char(pf(i).r(1))]]; 
%	for j = 2:length(pf(i).r)
%		str = [str,['     ',char(pf(i).r(j))]];
%	end
%end

if check_option(varargin,'short')
  str = {};
else
  str = {[' crystal symmetry:  ' char(pf(1).CS)],...
    [' specimen symmetry: ' char(pf(1).SS)]};  
end
for i = 1:numel(pf)
	toadd = [' h = ',char(pf(i).h)];
  toadd = [toadd,[', r = ',char(pf(i).r(1),'short')]]; 
	for j = 2:length(pf(i).r)
		toadd = [toadd,[', ',char(pf(i).r(j),'short')]];
  end
  toadd = [toadd ', ' pf(i).comment];
  str = [str,toadd];
end

str = char(str');
