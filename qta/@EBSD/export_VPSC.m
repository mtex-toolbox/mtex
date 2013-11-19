function export_VPSC(ebsd,filename,varargin)
% export EBSD to the VPSC format
%
%% Syntax
% export_VPSC(ebsd,'file.txt')
%
%% Input
%  ebsd     - ebsd data to be exported
%  filename - name of the ascii file
%
%% See also
% EBSDImportExport
  
% allocate memory
d = zeros(numel(ebsd),4);

% add Euler angles
d(:,1:3) = get(ebsd,'Euler',varargin{:});
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

w = get(ebsd,'weights');

% add weight
d(:,4) = w./ sum(w);

fid = efopen(filename,'w');

% header
% fourth line has to include the angle convention (B for Bunge)
% and the total number of grains in the phase
fprintf(fid,'\n\n\nB %d\n',numel(ebsd));

fprintf(fid,'%7.2f %7.2f %7.2f %11.7f\n',d');

fclose(fid);
