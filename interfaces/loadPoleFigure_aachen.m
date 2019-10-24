function pf = loadPoleFigure_aachen(fname,varargin)
% import data fom aachen ptx file
%
% Syntax
%   pf = loadPoleFigure_aachen_exp(fname)
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

ih = 1;
dig = 4;
col = 18;

while ~feof(fid)
  
  try
    
    cfound = false;
    % get comment line
    while ~cfound
            
      comment = fgetl(fid);
      
      %check whether this is not a data line
      if length(comment)==dig*col
        comment = reshape(comment(1:dig*col),dig,col).';
        cfound =  length(str2num(comment)) ~= col; %#ok<ST2NM>
      else
        cfound = true;
      end
    end
    comment = strtrim(comment);
      
    % one line describing hkl and grid of specimen directions
    %  003 hxxxx  5.00 5.00 90.00    1    0  (12f6.0)
    l = fgetl(fid);
    try
      cs = crystalSymmetry(strtrim(l(6:10)),'silent');
    catch %#ok<CTCH>
      cs = crystalSymmetry('m-3m');
    end
    h{ih} = string2Miller(l(1:5),cs);
    
    dtheta = str2double(l(11:15));
    dphi   = str2double(l(16:20));
    maxtheta = str2double(l(21:25));
    iwin = str2double(l(26:30));
    isim = str2double(l(31:35));
    fmt= regexp(l(36:end),'\s*\((\d+)f(\d+)','tokens');
    if length(fmt) == 1
      fmt = fmt{1};
      col = str2double(fmt(1));
      dig = str2double(fmt(2));
    end
    
    % next line contains multiplikator
    %  1000 .500 -112    0   0.   experimental data
    l = fgetl(fid);
    fakt = str2double(l(1:6));
    
    assert(0.5 < dtheta && 20 > dtheta && 0.5 < dphi && 20 > dphi &&...
      10 <= maxtheta && maxtheta <= 90 && fakt > 0 && col > 0 && dig > 0);

    % ------------- generate specimen directions --------------------
    if isim == 0
      maxphi = 360;
    elseif isim == 2
      maxphi = 180;
    elseif isim == 4
      maxphi = 90;
    else
      error('Wrong value for "isim"');
    end
    rho   = (0:dphi:maxphi-dphi) * degree;
    theta = ((1-iwin)*dtheta/2:dtheta:maxtheta)*degree;
    
    r{ih} = regularS2Grid('theta',theta,'rho',rho,'resolution',min(dtheta,dphi)*degree,'antipodal');
 
    % ---------------- read data ------------------------------------
    
    d{ih} = [];
    while length(d) < length(r) && ~feof(fid)
      l = fgetl(fid);
      if length(l)<dig*col, 
        continue;
      end
      l = reshape(l(1:dig*col),dig,col).';
      d{ih} = [d{ih};str2num(l)]; %#ok<AGROW,ST2NM>
    end
            
    ih = ih +1;
    
  catch %#ok<CTCH>
    if ih == 1, interfaceError(fname,fid);end
  end
end
fclose(fid);

% --------------- generate Polefigure ---------------------------
try
  pf = PoleFigure(h,r,d,cs,varargin{:},'comment',comment);
catch
  interfaceError(fname,fid);
end

%Aachen-Format:
%==============
%1. Zeile: text2  78 characters
%2. Zeile: hkl    (miller indices, 5 characters)
%          xxxx   ( kristall system, 5 characters, meist unbenutzt)
%          dteta  (polwinkel-schrittweite des messrasters
%          dphi   (azimuth-schrittweite des messrasters)
%          tetlim (maximaler polwinkel )
%          iwin   (0=position der daten in den mitten der rasterfelder,
%                  1=position auf den ecken)
%          isym   (0=vollst?ndige polfigur, 2= halbe polfigur,
%                  4=viertel polfigur)
%          fmt    (leseformat der daten)
%3. Zeile: mult   (faktor mit dem die daten multipliziert wurden)
%          ----   20 unbenutzte characters, text1: weitere 50 character
%
%In der Aachen-datei k???nnen mehrere Messungen hintereinander stehen, hier 2.
%--------------------------------------------------------------------------------
