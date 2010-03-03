function pf = loadPoleFigure_philips(fname,varargin)
% load philips *.txt file 
%
%% Input
% fname - file name
%
%% Output
% pf    - @PoleFigure
%
%% See also
% interfacesPoleFigure_index philips_interface loadPoleFigure

fid = efopen(fname);
  
try

  % read header
  
  % skip the first 17 lines
  textscan(fid,'%s',17,'delimiter','\n','whitespace','');
  
  % ckeck 18th line
  % ~isempty(strfind(l,'Start'))
  l = fgetl(fid);
  assert(~isempty(strfind(l,'Start')) ...
    && ~isempty(strfind(l,'End'))...
    && ~isempty(strfind(l,'Step')));
  
  % read psi (start stop step) and phi (start stop step)
  % and generate grid of specimen directions
  d = textscan(fid,'%*s %f %f %f\n',2);

  assert_grid(d{1}(1),d{3}(1),d{2}(1),d{1}(2),d{3}(2),d{2}(2),'degree');
  theta = (d{1}(1):d{3}(1):d{2}(1))*degree;
  rho = (d{1}(2):d{3}(2):d{2}(2))*degree; 
  r = S2Grid('theta',theta,'rho',rho(1:end-1),'antipodal');
  
  % one free line
  assert(isempty(fgetl(fid)));
  
  % read hkl
  h = string2Miller(fgetl(fid));
  c = ones(1,length(h));
  
  % skip the next 6 lines
  textscan(fid,'%s',6,'delimiter','\n','whitespace','');

  % read intensities
  d = fscanf(fid,'%e',[length(theta)+1,length(rho)]);
  d = d(2:end,:);
  
  assert(all(size(d.')==size(r)));
  
  fclose(fid);
  pf = PoleFigure(h,r,d.',symmetry('cubic'),symmetry,'superposition',c,varargin{:}); 
catch
  error('format Philips does not match file %s',fname);
end
