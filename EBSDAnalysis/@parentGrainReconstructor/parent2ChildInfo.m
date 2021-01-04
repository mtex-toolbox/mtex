function OR = parent2ChildInfo(job,varargin)   
% Extract OR information
%
% Input
%  job - @parentGrainReconstructor
%  varargin - 'silent': suppress command window output
% Output
%  OR       - structure containing OR information

assert(~isempty(job.p2c), 'No p2c defined. Please use the command ''calcParent2Child''.');
OR.p2c = job.p2c;

% Parallel planes and directions
[OR.plane.parent,OR.plane.child,OR.direction.parent,OR.direction.child] = ...
                    round2Miller(OR.p2c,'maxIndex',15);    
                
% Misorientation of rational OR
OR.p2cRational = orientation('map',...
                               OR.plane.parent,OR.plane.child,...
                               OR.direction.parent,OR.direction.child); 
                           
% Deviation angle between rational and actual OR
OR.devAngle.plane = min(angle(OR.p2c*OR.plane.parent.symmetrise,OR.plane.child));
OR.devAngle.direction = min(angle(OR.p2c*OR.direction.parent.symmetrise,OR.direction.child));
 
%Misorientation axes
OR.p2cAxis.parent = axis(OR.p2c,job.csParent);
OR.p2cAxis.parent = setDisplayStyle(OR.p2cAxis.parent,'direction');
OR.p2cAxis.child = axis(OR.p2c,job.csChild);
OR.p2cAxis.child = setDisplayStyle(OR.p2cAxis.child,'direction');

%Variants
OR.variants.orientation = OR.p2c.variants;
OR.variants.c2c = OR.p2c.variants*inv(OR.p2c.variants((job.variantMap(1))));
OR.variants.angle = angle(OR.variants.c2c);
OR.variants.axis = axis(OR.variants.c2c,job.csChild);
OR.variants.axis = setDisplayStyle(OR.variants.axis,'direction');
OR.variants.id = job.variantMap;

%Screen output
if check_option(varargin,'silent'); return; end
 
screenPrint('Step','OR info:');
screenPrint('SubStep',sprintf(['OR misorientation angle = ',...
    num2str(angle(OR.p2c)./degree),'º']));

screenPrint('Step','Parallel planes');
screenPrint('SubStep',sprintf(['Closest parent plane = ',...
    sprintMiller(OR.plane.parent,'round')]));
screenPrint('SubStep',sprintf(['Closest child plane = ',...
    sprintMiller(OR.plane.child,'round')]));
screenPrint('SubStep',sprintf(['Ang. dev. from parallel plane relationship from OR = ',...
    num2str(OR.devAngle.plane./degree),'º']));

screenPrint('Step','Parallel directions');
screenPrint('SubStep',sprintf(['Closest parent direction = ',...
    sprintMiller(OR.direction.parent,'round')]));
screenPrint('SubStep',sprintf(['Closest child direction = ',...
    sprintMiller(OR.direction.child,'round')]));
screenPrint('SubStep',sprintf(['Ang. dev. from parallel directions relationship from OR = ',...
    num2str(OR.devAngle.direction./degree),'º']));

screenPrint('Step','OR misorientation rotation axes'); 
screenPrint('SubStep',sprintf(['Parent rot. axis = ',...
    sprintMiller(OR.p2cAxis.parent)]));
screenPrint('SubStep',sprintf(['child rot. axis = ',...
    sprintMiller(OR.p2cAxis.child)]));

screenPrint('Step','Angle & rot. axes of unique variants');

for jj = 1:length(OR.variants.orientation)
    ii = OR.variants.id(jj);
    screenPrint('SubStep',sprintf([num2str(jj),': ',...
                 num2str(OR.variants.angle(ii)./degree,'%2.2f'),...
                 'º / ',sprintMiller(OR.variants.axis(ii))]));
end


  