function plotParent2Child(job, varargin)
% Plot pole figure of child variants
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
for ii = 1:24
    plotPDF(vars(ii),...
    colorScale(job.variantMap(ii),:),hChild,...
    'equal','antipodal',...
    'MarkerSize',8,'LineWidth',1,'MarkerEdgeColor',[0 0 0],'nosymmetry',...
    'label',job.variantMap(ii),'fontsize',10,'fontweight','bold');
    hold on
end
% Plot cube axes
plot(Miller(1,0,0,job.csChild),'plane','linecolor','k') 
plot(Miller(0,1,0,job.csChild),'plane','linecolor','k') 
plot(Miller(0,0,1,job.csChild),'plane','linecolor','k') 
% Change figure name
set(f,'Name',strcat('PDF of child variants'),'NumberTitle','on');
