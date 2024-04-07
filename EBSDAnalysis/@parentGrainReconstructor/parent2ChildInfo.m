function OR = parent2ChildInfo(job)   
% Extract OR information
%
% Syntax
%   OR = parent2ChildInfo(job)
%
% Input
%  job - @parentGrainReconstructor
%
% Options
%  silent - suppress command window output
%
% Output
%  OR - structure containing OR information

assert(~isempty(job.p2c), 'No p2c defined. Please use the command ''calcParent2Child''.');
OR.p2c = job.p2c;

% Parallel planes and directions
[OR.plane.parent,OR.plane.child,OR.direction.parent,OR.direction.child] = ...
  round2Miller(OR.p2c,'maxIndex',8);
                
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
OR.variants.c2c = OR.p2c.variants*inv(OR.p2c.variants(1));
OR.variants.angle = angle(OR.variants.c2c);
OR.variants.axis = axis(OR.variants.c2c,job.csChild);
OR.variants.axis = setDisplayStyle(OR.variants.axis,'direction');

%Screen output

screenPrint('Step','OR info:');
screenPrint('SubStep',sprintf(['OR misorientation angle = ',...
  num2str(angle(OR.p2c)./degree),'°']));

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
  ii = job.variantMap(jj);
  screenPrint('SubStep',sprintf([num2str(jj),': ',...
    num2str(OR.variants.angle(ii)./degree,'%2.2f'),...
    'º / ',sprintMiller(OR.variants.axis(ii))]));
end

end

%% Set Display Style of Miller objects
function m = setDisplayStyle(millerObj,mode)
m = millerObj;
if isa(m,'Miller')
  if any(strcmpi(m.CS.lattice,{'hexagonal','trigonal'}))
    if strcmpi(mode,'direction')
      m.dispStyle = 'UVTW';
    elseif strcmpi(mode,'plane')
      m.dispStyle = 'hkil';
    end
  else
    if strcmpi(mode,'direction')
      m.dispStyle = 'uvw';
    elseif strcmpi(mode,'plane')
      m.dispStyle = 'hkl';
    end
  end
end
end


%% ScreenPrint
function screenPrint(mode,varargin)
switch mode
  case 'StartUp'
    titleStr = varargin{1};
    fprintf('\n*************************************************************');
    fprintf(['\n                 ',titleStr,' \n']);
    fprintf('*************************************************************\n');
  case 'Termination'
    titleStr = varargin{1};
    fprintf('\n*************************************************************');
    fprintf(['\n                 ',titleStr,' \n']);
    fprintf('*************************************************************\n');
  case 'SegmentStart'
    titleStr = varargin{1};
    fprintf('\n------------------------------------------------------');
    fprintf(['\n     ',titleStr,' \n']);
    fprintf('------------------------------------------------------\n');
  case 'Step'
    titleStr = varargin{1};
    fprintf([' -> ',titleStr,'\n']);
  case 'SubStep'
    titleStr = varargin{1};
    fprintf(['    - ',titleStr,'\n']);
  case 'SegmentEnd'
    fprintf('\n- - - - - - - - - - - - - - - - - - - - - - - - - - - \n');
end
end

%% Print Crystal Planes
function s = sprintMiller(mil,varargin)
if any(strcmpi(mil.dispStyle,{'hkl','hkil'}))
  if strcmpi(mil.dispStyle,'hkil')
    mill = {'h','k','i','l'};
  elseif strcmpi(mil.dispStyle,'hkl')
    mill = {'h','k','l'};
  end
  s = '(';
  for i = 1:length(mill)
    if check_option(varargin,'round')
      s = [s,num2str(round(mil.(mill{i}),0))]; %#ok<AGROW>
    else
      s = [s,num2str(mil.(mill{i}),'%0.4f')]; %#ok<AGROW>
    end
    if i<length(mill)
      s = [s,',']; %#ok<AGROW>
    end
  end
  s = [s,')'];
elseif any(strcmpi(mil.dispStyle,{'uvw','UVTW'}))
  if strcmpi(mil.dispStyle,'UVTW')
    mill = {'U','V','T','W'};
  elseif strcmpi(mil.dispStyle,'uvw')
    mill = {'u','v','w'};
  end
  s = '[';
  for i = 1:length(mill)
    if check_option(varargin,'round')
      s = [s,num2str(round(mil.(mill{i}),0))]; %#ok<AGROW>
    else
      s = [s,num2str(mil.(mill{i}),'%0.4f')]; %#ok<AGROW>
    end
    if i<length(mill)
      s = [s,',']; %#ok<AGROW>
    end
  end
  s = [s,']'];
end
end
