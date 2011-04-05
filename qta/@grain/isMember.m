function b = isMember(grains,grains2)
% checks whether grains are within a given set.
%
%% Syntax
% b = ismember(grains, grains2) - returns an array the same size as |grains|, 
%    containing logical 1 (true) where the elements of |grains| are in the set
%    |grains2|, and logical 0 (false) elsewhere. 
%
%% Example
% return all grains which are not neighbour of a specific phase
%    
%    loadaachen;
%    [grains,ebsd] = calcGrains(ebsd);
% 
%    gr1 = link(grains,ebsd(1));
%    gr2 = link(grains,ebsd(2:end));
%    ngr1 = gr1(~isMember(gr1,neighbours(gr1,gr2)))
% 
%    hold on
%    plot(gr1,'property',0)
%    plot(gr2,'property',1)
%    plot(ngr1,'property',2)
%    plotboundary(grains)
%    hold off
%    colormap(prism)
%    legend('gr1','gr2','ngr1')
%



b = ismember(get(grains,'id'),get(grains2,'id'));