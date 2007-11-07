function bg = getbg(pf,h)
% get raw pole figure data
%
%
%% Input
%  pf - @PoleFigure
%  h  - @Miller
%
%% Output
%  bg - [double] background intensities
%
%% See also
% PoleFigure/getdata
%
%% TODO

if nargin == 2
	index = [];
	for i = 1:length(pf)
		if any(pf(i).h == h), index = [index,i];end %#ok<AGROW>
	end
else 
	index = 1:length(pf);
end

bg = [];
for i=1:length(index)
    bg = [bg;reshape(pf(index(i)).bgdata,[],1)];
end
