function str = char(pf,varargin)
% standard output


if check_option(varargin,'short')
  str = {};
else
  str = {[' crystal symmetry:  ' char(pf(1).CS)],...
    [' specimen symmetry: ' char(pf(1).SS)]};  
end
for i = 1:numel(pf)
	toadd = ['h = ',char(pf(i).h)];
  toadd = [toadd,[', r = ',char(pf(i).r,'short')]]; 
%   toadd = [toadd ', ' pf(i).comment];
  str = [str,toadd];
end

str = char(str');
