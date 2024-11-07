function p1 = plotTDF(bc,pd,varargin)
% Wrapper for the Matlab polar plot, can be used with calcTDF
%
% Input
%  bc - azimuth value
%  pd - polar value
%
% Options
%  nogrid   - get rid of grid on polar plot
%  nolabels - get rid of polar labels
%  linewidth - 
%  linecolor -
%  linestyle -
%

p1 = polarplot(bc,pd);
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
  txA(k).FontSize = getMTEXpref('FontSize')-4;
end




end
