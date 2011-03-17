function pf = loadPoleFigure_D5000(fname,varargin)
% load D5000 data file
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


[path,name,ext] = fileparts(fname);

if strcmpi(ext,'.dat')
  
  fid = fopen(fname,'r');
  d = [];
  p = 0;
  while ~feof(fid)
    line = fgetl(fid);
    
    if strfind(line,'*Pole figure:')
      p = p+1;
      h(p) = string2Miller(line(14:end));
      d{p} = [];
      theta{p} = [];
    elseif strfind(line,'*Khi')
      theta{p} = [theta{p} sscanf(line(7:end),'%f')];
      bg = [];
    elseif strfind(line,'background')
      bg = [bg sscanf(line(end-8:end),'%8f')];
      if numel(bg)>1
        bg = mean(bg);
      end
    elseif strfind(line,'*')
      %other information
    else
      for l=1:8:64
        d{p} = [d{p} sscanf(line(l:l+7),'%f')-bg];
      end
    end
  end
  fclose(fid);
  
  
  for p=1:numel(h)
    n = numel(d{p})/numel(theta{p});
    r = S2Grid('theta',theta{p}*degree,'rho',linspace(0,2*pi*(n-1/n),n));
    pf(p) = PoleFigure(h(p),r,d{p},symmetry('cubic'),symmetry);
  end
  
elseif strcmpi(ext,'.pwd')
  
  fid = fopen(fname,'r');
  p = 0;
  while ~feof(fid)
    line = fgetl(fid);
    
    if strfind(line,'R')
      p = p+1; k=1;
      h(p) = string2Miller(line(2:end));
    elseif isempty(regexp(line,'[*#]'))
      dat = sscanf(line,'%f');
      theta(p,k) = dat(1);
      def(p,k)  = dat(2);
      defbg(p,k) = dat(3);
      k = k+1;
    end
    
  end
  fclose(fid);
  
  theta = theta*degree;
  d = def-defbg;
  
  for p=1:numel(h)
    th = theta(p,:);
    r = S2Grid(sph2vec(th,zeros(size(th))));
    pf(p) = PoleFigure(h(p),r,d(p,:),symmetry('cubic'),symmetry);
  end
else
  error('format does not match!')
end

% plot(pf)
% plot(delete(pf,getdata(pf)<0))
