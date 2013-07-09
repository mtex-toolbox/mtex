function pf = loadPoleFigure_xrd(fname,varargin)
% import data fom aachen xrd file
%
%% Syntax
% pf = loadPoleFigure_xrd(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure


%%
rhoStartToken = {'*MEAS_SCAN_START "','*START		=  '};
rhoStepToken = {'*MEAS_SCAN_STEP "','*STEP		=  '};
rhoStopToken = {'*MEAS_SCAN_STOP "','*STOP		=  '};
thetaToken = {'*MEAS_3DE_ALPHA_ANGLE "','*PF_AANGLE	=  '};

%% read header

h = file2cell(fname,1);

if isempty(strmatch(h,'*RAS_DATA_START'))
  interfaceError(fname);
end

h = file2cell(fname);

% look through different versions of the xrd format
for i = 1:length(rhoStartToken)
  
  try
    %search data for pole angles
    rhoStart = readToken(h,rhoStartToken{i});
    rhoStep = readToken(h,rhoStepToken{i});
    rhoStop = readToken(h,rhoStopToken{i});
    rho = (rhoStart(1):rhoStep(1):rhoStop(1))*degree;
    theta = pi/2-readToken(h,thetaToken{i})*degree;
    
    r = S2Grid('regular','theta',theta,'rho',rho);
  catch %#ok<CTCH>
    continue
  end
  
  if ~isempty(r), break;end
end


assert(numel(r)>0);
h = string2Miller(fname);

%% read data

fid = efopen(fname);

d = cell2mat(textscan(fid,'%n','CommentStyle','*','Whitespace',' \n,',...
  'MultipleDelimsAsOne',true));

% if there are more then one value per direction take the second one
if numel(d) > numel(r)
  
  d = d(2:3:end);
  
end

fclose(fid);

%% define Pole Figure

cs = symmetry('cubic');
ss = symmetry('-1');

pf = PoleFigure(h,r,d,varargin{:});


function value = readToken(str,token)

l = strncmp(token,str,length(token));

value = [];
for k = find(l)
  value = [value,sscanf(str{k},[token '%f'])]; %#ok<*AGROW>
end