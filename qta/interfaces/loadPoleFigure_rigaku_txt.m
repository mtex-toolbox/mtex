function pf = loadPoleFigure_rigaku_txt(fname,varargin)
% import data fom ana file
%
%% Syntax
% pf = loadPoleFigure_rigaku_txt(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure

fid = efopen(fname);

try
  % first line comment
  comments  = textscan(fid,'%s\t%s',7,'delimiter','\n\t','MultipleDelimsAsOne',true);
  [p,comment] = fileparts(fname);
  
  ntheta = 0;
  rho = [];
  d = [];
  
  while ~feof(fid)
    
    % read header
    header = textscan(fid,'%s\t%s',11,'delimiter','\n\t','MultipleDelimsAsOne',true);
    
    rhoMin = str2double(readfield(header,'Start'));
    rhoMax = str2double(readfield(header,'Stop'));
    rhoStep = str2double(readfield(header,'Step'));
    assert(~isempty(rhoMin) && ~isempty(rhoMax) && ~isempty(rhoStep));
    %rho = linspace(rhoMin,rhoMax,fix((rhoMax-rhoMin)/rhoStep));
    
    % read data
    data = textscan(fid,'%f\t%f',1+fix((rhoMax-rhoMin)/rhoStep));
    
    % new theta angle
    ntheta = ntheta + 1;
    nrho(ntheta) = numel(data{1}); %#ok<AGROW>
    
    % get specimen directions
    rho = [rho;data{1} * degree]; %#ok<AGROW>
    
    % append data
    d = [d;data{2}]; %#ok<AGROW>
    
  end
  
  theta = linspace(0,80*degree,ntheta);
  theta = rep(theta,nrho)';
  r = vector3d('polar',theta,rho); 
  
  % append last pole figure
  pf = PoleFigure(string2Miller(fname),S2Grid(r),d,'comment',comment,varargin{:});
  
catch
  interfaceError(fname,fid);
end

fclose(fid);

end

function field = readfield(h,pattern)

ind = strncmp(h{1},pattern,length(pattern));
if nnz(ind) > 1
  ind = strcmp(h{1},pattern);
end

field = h{2}(ind);

end
