function ebsd = loadEBSD_ACOM(fname,varargin)
% read ACOM files (converted from *.res ASTAR)
%
% Syntax
%   ebsd = loadEBSD_ACOM(fname)
%   ebsd = loadEBSD_ACOM(fname,'convertSpatial2EulerReferenceFrame')
%   ebsd = loadEBSD_ACOM(fname,'convertEuler2SpatialReferenceFrame')
%
% Input
%  fname - file name
%
% Flags
%  convertSpatial2EulerReferenceFrame - change x and y values such that spatial and Euler reference frame coincide, i.e., rotate them by 180  degree
%  convertEuler2SpatialReferenceFrame - change the Euler angles such that spatial and Euler reference frame coincide, i.e., rotate them by 180  degree
%

ebsd = EBSD;

% check that this is a ACOM text file
fid = fopen(fname);
h1 = fgetl(fid);
fclose(fid);
if isempty(strfind(h1,'ACOM RES results'));
  error('MTEX:wrongInterface','Interface "ACOM" does not fit file format!');
elseif check_option(varargin,'check')
  return
end

% read data
try
  % read full file to be able to determine the assinged phases in all pixel
  % of orientation map
  [A,ffn,nh,SR,hlS,fpos]=txt2mat(fname,'RowRange',[1,1000],'infoLevel',0);
  % read header into cells
  hlP = strfind(hlS,'#');
  hlPL=length(hlP);
  hl=cell(hlPL-1,1);
  for i=1:hlPL-1
    hl{i,1}=hlS(hlP(i):hlP(i+1)-1);
  end
  
  %get the phases that are assigned in all pixel
  PhasesInFile=unique(A(:,8));
  
  phasePos = strmatch('# Phase',hl);
  
  if isempty(phasePos), phasePos=1; end
  
  
  try
    B=zeros(length(A(:,8)),1);
    phaseCount=1;
    for i = length(phasePos):-1:1
      pos = phasePos(i);
      
      % load phase number
      if pos==1 %if phase match is empty--> only one phase exists in file
        pos=4;
        phase=1;
      else
        phase = sscanf(hl{pos},'# Phase %u');
      end
                  
      %maybe it is not assigned in pixel
      if any(phase==PhasesInFile)
        
        % load mineral data
        mineral = hl{pos+1}(15:end);
        mineral = strtrim(mineral); %removes leading and trailing white space
        laue = sscanf(hl{pos+3},'# Symmetry %s');
        lattice = sscanf(hl{pos+4},'# LatticeConstants %f %f %f %f %f %f');
        options = {};
        switch laue
          case {'-3m' '32' '3' '62' '6'}
            options = {'X||a'};
          case '2'
            options = {'X||a*'};
          case '1'
            options = {'X||a'};
          case '20'
            laue = {'2'};
            options = {'y||b','z||c'};
          otherwise
            if lattice(6) ~= 90
              options = {'X||a'};
            end
        end
        
        % #ok<AGROW>
        cs{phaseCount} = crystalSymmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:});
        
        B(A(:,8)==phase)=phaseCount;
        hl{pos}(9)=num2str(phaseCount);
        ReplaceExpr{i} = {mineral,int2str(i)};
        phaseCount=phaseCount+1;
      else
        hl{pos}(9)='0';
      end
    end
    assert(~isempty(cs));
  catch %#ok<CTCH>
    interfaceError(fname);
  end
  
  if check_option(varargin,'check'), return;end
  
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
    'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y' 'index' 'rel' 'Phase' 'sd'},...
    'Columns',1:9,varargin{:},'header',nh);
  
catch
  interfaceError(fname);
end

% change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector+yvector,180*degree),'keepEuler');
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector+yvector,180*degree),'keepXY');
end

