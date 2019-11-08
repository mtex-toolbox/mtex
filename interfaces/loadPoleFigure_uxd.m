function pf = loadPoleFigure_uxd(fname,varargin)
% import data fom ana file
%
% Syntax
%   pf = loadPoleFigure_uxd(fname)
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
 
  lastTh = [];  
  npf = 1;
  
  while ~feof(fid)
    
    % read header
    header = textscan(fid,'_%s %q%*s%*s','Delimiter','=','CommentStyle',';');
    
    % read data
    data = textscan(fid,'%f'); data = data{1};
    
    % THETA
    th = readfield(header,'THETA');
    assert(str2double(th)>0 && str2double(th)<90);
    
    % if theta is different from last theta start new polfigure
    if ~strcmp(lastTh,th)
      if ~isempty(lastTh)
        allH{npf} = Miller(1,0,0,crystalSymmetry);
        allR{npf} = r;
        allI{npf} = d;       
        npf = npf + 1;
      end
      lastTh = th;
      r = vector3d;
      d = [];
    end
    
    % get specimen directions
    theta = str2double(readfield(header,'KHI'))*degree;
    assert(theta>=0 && theta<=90*degree);
    
    % if every second data value increases by a constant value
    % this polar angle
    if ~any(diff(diff(data(1:2:end))))
      rho = data(1:2:end)*degree;
      data = data(2:2:end);      
    else
      rho = linspace(0,2*pi,numel(data)+1).';
      rho(end)=[];
    end
    d = [d;data]; %#ok<AGROW>
    r = [r;vector3d.byPolar(theta,rho)]; %#ok<AGROW>   
  end
  
  % append last pole figure
  allH{npf} = string2Miller(fname);
  allR{npf} = r;
  allI{npf} = d;
  
  % define pole figure
  pf = PoleFigure(allH,allR,allI,varargin{:});
    
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
