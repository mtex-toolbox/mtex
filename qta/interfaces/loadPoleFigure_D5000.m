function pf = loadPoleFigure_D5000(fname,varargin)
% load dubna cnv file 
%
%% Syntax
% pf = loadPoleFigure_D5000(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% loadPoleFigure ImportPoleFigureData


fid = fopen(fname,'r');

d = [];
p = 0;
while ~feof(fid)
  line = fgetl(fid);
  
  if strfind(line,'*Pole figure:')
    if p>0
      n = numel(d)/numel(th);
      r = S2Grid('theta',th*degree,'rho',linspace(0,2*pi*(n-1/n),n));      
      pf(p) = PoleFigure(h,r,d,symmetry,symmetry); 
    end
    h = string2Miller(line(14:end));
    d = [];
    th = [];
    p = p+1;
  elseif strfind(line,'*Khi')
    th = [th sscanf(line(7:end),'%f')];
    c = [];
  elseif strfind(line,'Rescaled')
    c = [c sscanf(line(end-8:end),'%8f')];
    if numel(c)>1
      c = mean(c);
    end
  elseif strfind(line,'*')
    %other information
  else   
    for l=1:8:64
     d = [d sscanf(line(l:l+7),'%f')-c];
    end
  end
end
fclose(fid);

% plot(pf)
% plot(delete(pf,getdata(pf)<0))
