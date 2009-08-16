function pf = loadPoleFigure_beartex(fname,varargin)
% import data fom BeaTex file
%
%% Syntax
% pf = loadPoleFigure_beartex(fname,<options>)
%
%% Input
%  fname    - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfacesPoleFigure_index beartex_interface loadPoleFigure


fid = efopen(fname);

ipf = 1;

while ~feof(fid)

  try
%% read header
	  
    % first 5 lines --> comments
    comment = textscan(fid,'%s',5,'delimiter','\n','whitespace','');
    comment = char(comment{1}{1});comment = comment(1:40);

    % read crystal symmetry
    s = str2num(fgetl(fid)); %#ok<ST2NM>
    assert(all(s(1:6)>0 & s(1:6)<180));

%% guess crystal symmetry
    laue = 'triclinic';
    if all(s(4:5)==90)
      if s(6)==90
        if all(s(1:2)==s(3))
          laue = 'cubic';
        elseif s(1) == s(2) 
          laue = 'tetragonal';
        else
          laue = 'orthorhombic';
        end
      elseif s(6) == 120
        laue = 'trigonal';        
      end     
    end
    cs = symmetry(laue,[s(1) s(2) s(3)],[s(4) s(5) s(6)]);

%% get Miller indece    
    % read Miller, theta (start stop step) and rho (start stop step)
    % and generate grid of specimen directions
    s = fgetl(fid);
    h = str2double(s(1:4));
    k = str2double(s(5:7));
    l = str2double(s(8:10));
    assert(all(round([h k l]) == [h k l] & [h k l]>=0 & [h k l]<10));
    h = Miller(h,k,l,cs);

%% generate specimen directions    
    theta(1) = str2double(s(11:15));
    theta(2) = str2double(s(21:25));
    theta(3) = str2double(s(16:20));
    assert(all(theta>=0 & theta <= 90));
    
    theta = (theta(1):theta(2):theta(3))*degree;
    assert(~isempty(theta));
    
    rho(1) = str2double(s(26:30));
    rho(2) = str2double(s(36:40));
    rho(3) = str2double(s(31:35));
    assert(all(rho>=0 & rho <= 360));
    
    rho = (rho(1):rho(2):rho(3))*degree;
    assert(~isempty(rho));
    r = S2Grid('theta',theta,'rho',rho,'antipodal');
	
%% read data    
    d = [];
    while length(d) < GridLength(r)
      l = fgetl(fid);
      l = reshape(l(2:end),4,[]).';
      d = [d;str2num(l)]; %#ok<ST2NM>
    end
          
%% generate Polefigure    
    pf(ipf) = PoleFigure(h,r,d,cs,symmetry,'comment',comment,varargin{:}); 
  
    % skip one line
    fgetl(fid);
    ipf = ipf+1;
  catch
    if ~exist('pf','var')
      error('format BearTex does not match file %s',fname);
    end
  end
end

fclose(fid);
