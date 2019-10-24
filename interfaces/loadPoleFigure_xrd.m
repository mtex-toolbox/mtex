function pf = loadPoleFigure_xrd(fname,varargin)
% import data fom aachen xrd file
%
% Syntax
%   pf = loadPoleFigure_xrd(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

pf = PoleFigure;

% tokens
rhoStartToken = {'*MEAS_SCAN_START\s*"(\S*)"','*START\s*=\s*(\S*)'};
rhoStepToken = {'*MEAS_SCAN_STEP\s*"(\S*)"','*STEP\s*=\s*(\S*)'};
rhoStopToken = {'*MEAS_SCAN_STOP\s*"(\S*)"','*STOP\s*=\s*(\S*)'};
thetaToken = {'*MEAS_3DE_ALPHA_ANGLE\s*"(\S*)"','*PF_AANGLE\s*=\s*(\S*)'};

% read file
if check_option(varargin,'check')
  h = file2cell(fname,1000);
else
  h = file2cell(fname);
end

% look through different versions of the xrd format
for i = 1:length(rhoStartToken)
  
  try
    %search data for pole angles
    rhoStart = readToken(h,rhoStartToken{i});
    rhoStep = readToken(h,rhoStepToken{i});
    rhoStop = readToken(h,rhoStopToken{i});
    rho = (rhoStart(1):rhoStep(1):rhoStop(1))*degree;
    theta = pi/2-readToken(h,thetaToken{i})*degree;
    
    r = regularS2Grid('theta',theta,'rho',rho);
  catch %#ok<CTCH>
    continue
  end
  
  if ~isempty(r), break;end
end

assert(~isempty(r));
if check_option(varargin,'check'), return;end

h = string2Miller(fname);

% ------------------------ read data -------------------------

fid = efopen(fname);

d = cell2mat(textscan(fid,'%n','CommentStyle','*','Whitespace',' \n,',...
  'MultipleDelimsAsOne',true));

% if there are more then one value per direction take the second one
if numel(d) > length(r)
  
  d = d(2:3:end);
  
end

fclose(fid);

% define Pole Figure 
pf = PoleFigure(h,r,d,varargin{:});

% ----------------------------------------------------------------
function value = readToken(str,token)

str = regexp(str,token,'tokens');
str = str(~cellfun('isempty',str));
value = cellfun(@(c) str2double(c{1}{1}),str);
