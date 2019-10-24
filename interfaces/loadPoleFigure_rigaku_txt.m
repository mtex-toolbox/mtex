function pf = loadPoleFigure_rigaku_txt(fname,varargin)
% import data fom ana file
%
% Syntax
%   pf = loadPoleFigure_rigaku_txt(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

fid = efopen(fname);

try 
  ntheta = 0;
  rho = [];
  d = [];
  
  fid = efopen(fname);
    
  while ~feof(fid)
  
    % read header
    while ~feof(fid)
      
      s = textscan(fid,'%s %s %*[^\n]',1,'delimiter','\t ,;','MultipleDelimsAsOne',1);      
          
      if isempty(s), continue;end
      if ~isnan(str2double(s{1})), break;end
      switch lower(char(s{1}))
        case 'start'
          rhoMin = str2double(char(s{2}));
        case 'stop'
          rhoMax = str2double(char(s{2}));
        case 'step'
          rhoStep = str2double(char(s{2}));
      end
    end
  
    % verify header
    assert(~isempty(rhoMin) && ~isempty(rhoMax) && ~isempty(rhoStep));
    
    numData = 1 + fix((rhoMax-rhoMin)/rhoStep);
    
    % read data
    data = textscan(fid,'%f %f %*[^\n]',numData-1,'delimiter','\t ,;','MultipleDelimsAsOne',1);
    % do not forget the last line from the header
    data{1} = [str2double(s{1});data{1}];
    data{2} = [str2double(s{2});data{2}];
        
    % new theta angle
    ntheta = ntheta + 1;
    nrho(ntheta) = numel(data{1}); %#ok<AGROW>
      
    % get specimen directions
    rho = [rho;data{1} * degree]; %#ok<AGROW>
    
    % append data
    d = [d;data{2}]; %#ok<AGROW>
    
  end
  
  theta = (ntheta-1:-1:0) .* rhoStep .* degree;
  assert(numel(theta)>4);
  
  theta = repelem(theta,nrho)';
  r = vector3d.byPolar(theta,rho); 
  
  % append last pole figure
  pf = PoleFigure(string2Miller(fname),r,d,varargin{:});
  
catch
  interfaceError(fname,fid);
end

fclose(fid);

end

