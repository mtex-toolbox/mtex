function pf = loadPoleFigure_uxd(fname,varargin)
% import data fom ana file
%
% Syntax
%   pf = loadPoleFigure_uxd(fname,<options>)
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
  % first line comment
  comment = fgetl(fid);
  [p,comment] = fileparts(fname);
  
  h = [];
  npf = 1;
  
  while ~feof(fid)
    
    % read header
    header = textscan(fid,'_%s %q%*s%*s','Delimiter','=','CommentStyle',';');
    
    % read data
    data = textscan(fid,'%f %f');
    
    % THETA
    th = readfield(header,'THETA');
    assert(str2double(th)>0 && str2double(th)<90);
    
    % new polfigure
    if ~strcmp(h,th)
      if ~isempty(h)
        pf(npf) = PoleFigure(Miller(1,0,0),r,d,symmetry('m-3m'),symmetry,'comment',comment); %#ok<AGROW>
        npf = npf + 1;
      end
      h = th;
      r = vector3d;
      d = [];
    end
    
    % get specimen directions
    theta = str2double(readfield(header,'KHI'))*degree;
    assert(theta>=0 && theta<=90*degree);
    
    % append data
    if all(isnan(data{2}))
      d = [d;data{1}]; %#ok<AGROW>
      rho = linspace(0,2*pi,numel(data{1})+1).';
      rho(end)=[];
    else
      d = [d;data{2}]; %#ok<AGROW>
      rho = data{1}*degree;
    end
    r = [r;vector3d('polar',theta,rho)]; %#ok<AGROW>
    
  end
  
  % append last pole figure
  pf(npf) = PoleFigure(string2Miller(fname),r,d,'comment',comment,varargin{:});
  
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
