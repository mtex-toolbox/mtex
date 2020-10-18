function p1 = plotTDF(bc,pd,varargin)
% Wrapper for the Matlab polar plot, can be used with calcTDF
%
% Input:
%   bc          - azimuth value
%   pd          - polar value
%
% Options:
%   nogrid      - get rid of grid on polar plot
%   nolabels    - get rid of polar labels
%   linewidth, linecolor, linestyle

[mtexFig,isNew] = newMtexFigure(varargin{:});

p1 = polar(bc,pd,'parent',mtexFig.gca);
% set linewidth
p1.LineWidth = get_option(varargin,'linewidth',2);
% set linecolor
if check_option(varargin,'lineColor')
  p1.Color = get_option(varargin,'linecolor',[0 0 0]);
end
% set linestyle
ls = get_option(varargin,'linestyle','-');
p1.LineStyle=ls;
p1.Tag='doNotDelete';

% fix FontSize
txA = findall(gca,'type','text');
for k=1:length(txA)
    txA(k).FontSize=getMTEXpref('FontSize')-4;
end

if check_option(varargin,'nogrid')
    % find all of the lines in the polar plot
    h = findall(gcf,'type','line');
    for k=1:length(h)
        id_del(k) = ~strcmp(h(k).Tag,'doNotDelete');
        % delete all other lines excet our plot
    end
    delete(h(id_del));
end

if check_option(varargin,'nolabels')
    % find and remove the radial text labels in the polar plot
    tx=findall(gcf,'type','text');
    for k=1:length(tx)
        id_delt(k) = strcmp(tx(k).HorizontalAlignment,'left');
    end
    delete(tx(id_delt));
end

% although it's inside an mtexFigure we need to set plotting conventions
mtexFig.setCamera('xAxisDirection',getMTEXpref('xAxisDirection'));
mtexFig.setCamera('zAxisDirection',getMTEXpref('zAxisDirection'));

% 
if isNew, mtexFig.drawNow(varargin{:});end
% 
% 
end
