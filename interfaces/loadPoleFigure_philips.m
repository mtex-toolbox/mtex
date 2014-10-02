function pf = loadPoleFigure_philips(fname,varargin)
% load philips *.txt file
%
% Input
% fname - file name
%
% Output
% pf    - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

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
  theta = textscan(fid,'%*s %f %f %f\n',1);
  rho = textscan(fid,'%*s %f %f %f\n',1);
  
  assert_grid(theta{1},theta{3},theta{2},rho{1},rho{3},rho{2},'degree');
  theta = (theta{1}:theta{3}:theta{2})*degree;
  rho = (rho{1}:rho{3}:rho{2})*degree;
  r = regularS2Grid('theta',theta,'rho',rho(1:end-1),'antipodal');
  
  % one free line
  assert(isempty(fgetl(fid)));
  
  % read hkl
  [h,ok] = string2Miller(fgetl(fid));
  if ~ok, h = string2Miller(fname);end;
  
  % skip the next 6 lines
  %textscan(fid,'%s',6,'delimiter','\n','whitespace','');
  
  % read intensities
  %d = fscanf(fid,'%e',[length(theta)+1,length(rho)]);
  
  d = txt2mat(fname,'InfoLevel',0);
  d = d.';
  d = d(2:end,:);
  assert(all(size(d.')==size(r)));
  pf = PoleFigure(h,r,d.',varargin{:});
catch
  interfaceError(fname,fid);
end

fclose(fid);
