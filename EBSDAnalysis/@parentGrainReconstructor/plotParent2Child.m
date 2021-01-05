function plotParent2Child(job, varargin)
% Plot pole figure of child variants
%
% Syntax
%   plotParent2Child(job)
%   plotParent2Child(job, oriParent)
%   plotParent2Child(job, hChild)
%   plotParent2Child(job, oriParent, hChild)
%
% Input
%  job - @parentGrainReconstructor
%  oriParent - @orientation Parent orientation
%  hChild - @Miller Plotting direction for the pole figure

assert(~isempty(job.p2c), 'No p2c defined. Please use the command ''calcParent2Child''.');
oriParent = getClass(varargin,'orientation',orientation.id(job.csParent));
hChild = getClass(varargin,'Miller',Miller(0,0,1,job.csChild,'hkl'));

%Compute variants
vars = variants(job.p2c,oriParent);

colorScale = jet(length(vars));
% Plot variants with equivalent orientations
f = figure;
plotPDF(vars,...
colorScale(job.variantMap,:),hChild,...
'equal','antipodal','points','all',...
'MarkerSize',6,'LineWidth',1,'MarkerEdgeColor',[1 1 1]);
hold on

% Plot unique variants with label
for ii = 1:length(job.p2c.variants)
    plotPDF(vars(ii),...
    colorScale(job.variantMap(ii),:),hChild,...
    'equal','upper',...
    'MarkerSize',8,'LineWidth',1,'MarkerEdgeColor',[0 0 0],'nosymmetry',...
    'label',job.variantMap(ii),'fontsize',10,'fontweight','bold');
    hold on
end
% Plot cube axes
plot(Miller(1,0,0,job.csParent),'plane','linecolor','k') 
plot(Miller(0,1,0,job.csParent),'plane','linecolor','k') 
plot(Miller(0,0,1,job.csParent),'plane','linecolor','k') 
% Change figure name
set(f,'Name',strcat('PDF of child variants'),'NumberTitle','on');
