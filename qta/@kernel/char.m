function c = char(k,varargin)
% kernel -> char

if check_option(varargin,'LATEX')
	c = [k.name ', p=' num2str(k.p1(1))];
else
	c = [k.name ', hw = ' int2str(gethw(k)*180/pi),mtexdegchar];
end
