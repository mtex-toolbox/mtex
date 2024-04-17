function selectInteractive(job,varargin)
% compute votes from grain boundaries
%
% Syntax
%
%   % compute votes from all p2c and c2c boundaries
%   job.calcGBVotes('threshold', 2*degree)
%
%   % compute votes only from p2c boundaries -> growth algorithm
%   job.calcGBVotes('p2c', 'threshold', 3*degree, 'tol', 1.5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - table of votes
%
% Options
%  p2c  - consider only parent / child grain boundaries
%  c2c  - consider only child / child grain boundaries
%  threshold - threshold fitting angle between job.p2c and the boundary OR
%  tolerance - range over which the probability increases from 0 to 1 (default 1.5)
%  numFit - number of fits to be computed
%


% datacursormode does not work with grains due to a Matlab bug
datacursormode off

% define a hand written selector
set(gcf,'WindowButtonDownFcn',{@doSelection,job});

end

function doSelection(~,~,job)

% remove old selection
ax = gca;
handleSelected = getappdata(ax,'handleSelected');
try delete(handleSelected); end %#ok<TRYNC>

% new grainid
pos = get(ax,'CurrentPoint');
localId = findByLocation(job.grains,[pos(1,1) pos(1,2)]);

if isempty(localId), return; end
grain = job.grains(localId);

% mark grains
hold on
handleSelected = plot(grain.boundary,'lineColor','w','linewidth',4);
hold off
setappdata(ax,'handleSelected',handleSelected);

votesFit = job.calcGBVotes(grain.id,'bestFit','reconsiderAll');
votesProb = job.calcGBVotes(grain.id,'reconsiderAll','numFit',24,'tolerance',5*degree,'curvatureFactor',1);

fig = figure(100);
clf(fig)
set(fig,'name',['grain: ' xnum2str(grain.id)])
numV = size(votesFit.parentId,2);
cKey = ipfHSVKey(job.csParent);

oriPV = variants(job.p2c,job.grainsPrior(localId).meanOrientation,votesFit.parentId);

bgColor = cKey.orientation2color(oriPV);
fgColor = bgColor .* sum(bgColor,2) < 1.5;

for n=1:numV
    
  handles.b{n} = uicontrol('Style','PushButton','Units','normalized',...
    'Position',[0.1 (n-1)/numV 0.8 0.9*1/numV],...
    'backGroundColor',bgColor(n,:),'ForegroundColor',fgColor(n,:),...
    'String',[xnum2str(votesFit.fit(n)./degree) ' - ' ...
    xnum2str(votesProb.prob(votesProb.parentId==votesFit.parentId(n))) ],...
    'Callback',{@setOri,job,localId,oriPV(n),ax}); %#ok<STRNU>
end

end

function setOri(~,~,job,id,pOri,ax)

job.grains(id).meanOrientation = pOri;
job.grains.update;

hold(ax,'on')
plot(job.grains(id),pOri,'parent',ax);
hold(ax,'off')

end

