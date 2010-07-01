function pf = loadPoleFigure_frame(fname,varargin)
% load bruker axs frame data format
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% interfacesPoleFigure_index loadPoleFigure


try
  fid = fopen(fname);
  A = fread(fid);
  fclose(fid);

  in = find(A == 10);
  A = sscanf(char(A(in(96):end)),'%f');

  A = reshape(A,sqrt(numel(A)),[]);  % 512^2 or 1024^2
  % imagesc(A);

  % frame to polar grid
  [ix iy data] = find(A);
  ix = (ix-size(A,2)/2);
  iy = (iy-size(A,2)/2);

  rho = atan2(iy,ix); % beta

  theta = sqrt((ix).^2+(iy).^2); %dist to center %check projection!
  theta = theta./(size(A,2)/pi); %alpha   

  assert(all((theta>0) & (theta<pi/2)) && all((rho>0) & (rho<2*pi)));
  h = string2Miller(fname);
  r = S2Grid(vector3d('polar',theta,rho));
  assert(numel(r) > 10);
    
  pf = PoleFigure(h,r,data,symmetry('cubic'),symmetry,'antipodal');
catch
   if ~exist('pf','var')
    error('format frame does not match file %s',fname);
  end
end

