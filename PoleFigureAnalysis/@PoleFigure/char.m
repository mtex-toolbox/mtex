function str = char(pf,varargin)
% standard output


if check_option(varargin,'short')
  str = {};
else
  str = {[' crystal symmetry:  ' char(pf.CS)],...
    [' specimen symmetry: ' char(pf.SS)]};  
end
for i = 1:pf.numPF
	toadd = ['h = ',char(pf.allH{i})];
  toadd = [toadd,[', r = ',char(pf.allR{i},'short')]]; 
  str = [str,toadd];
end

str = char(str');
