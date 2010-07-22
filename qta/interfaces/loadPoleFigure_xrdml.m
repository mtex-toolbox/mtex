function pf = loadPoleFigure_xrdml(fname,varargin)
% load xrdMeasurement (xrdml) file 
%
%% Syntax
% pf = loadPoleFigure_xrdml(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% ImportPoleFigureData

try
  [fdir,fn,ext] = fileparts(fname);
  assert(any(strcmpi(ext,{'.xml','.xrdml'})));
  doc = xmlread(fname);
catch
  error('file not found or format xrdml does not match file %s',fname);
end

xRoot = doc.getDocumentElement;

if strcmp(xRoot.getTagName,'xrdMeasurements')
  
  %begin import
  nodelist = xRoot.getElementsByTagName('xrdMeasurement');
  
  %loop over pole figures
  for i=0:nodelist.getLength-1
    
    d=[];
    current_theta = [];
    current_rho = [];
    
    %read current measurement
    xrdMeasurement = nodelist.item(i);
    scan = xrdMeasurement.getElementsByTagName('scan');  
    
    %read hkl from first entry
    try
      hkl_node = scan.item(0).getElementsByTagName('hkl').item(0).getChildNodes;
      hkl = 'hkl';
      for k=1:3
        h(k) = str2num(hkl_node.getElementsByTagName(...
          hkl(k)).item(0).getFirstChild.getNodeValue);
      end
      h = Miller(h(1),h(2),h(3));
    catch
      h = string2Miller(fname);
    end
    
    step_axis = xrdMeasurement.getAttribute('measurementStepAxis');

    %loop over all scan-data sets
    for ii=0:scan.getLength-1
      
      val = str2num(scan.item(ii).getElementsByTagName('intensities').item(0).getFirstChild.getNodeValue);
      time = str2num(scan.item(ii).getElementsByTagName('commonCountingTime').item(0).getFirstChild.getNodeValue);
      d = [d,val/time];
      
      %get start and stop position
      pos = scan.item(ii).getElementsByTagName('positions');
      rot_start = scan.item(ii).getElementsByTagName('startPosition').item(0); 
            
      %check units
      if strcmp(rot_start.getParentNode.getAttribute('unit'),'deg')
        isrho_deg=degree;
      else
        isrho_deg=1;
      end;
      
      start = isrho_deg * str2num(rot_start.getFirstChild.getNodeValue);
      stop = isrho_deg * str2num(scan.item(ii).getElementsByTagName('endPosition').item(0).getFirstChild.getNodeValue);
     
      %get theta
      for k=0:pos.getLength-1
        if strcmp(pos.item(k).getAttribute('axis'), char(step_axis))
          
          %check units
          if strcmp(pos.item(k).getAttribute('unit'),'deg')
            istheta_deg=degree;
          else
            istheta_deg=1; 
          end;
          
          %get theta
          theta = str2num(pos.item(k).getElementsByTagName('commonPosition').item(0).getFirstChild.getNodeValue);
          current_theta = [ current_theta; ...
            repmat(istheta_deg*theta,length(val),1)]; %pi/2-
        end
      end
      
      %get rho, mode="Continuous"
      current_rho = [current_rho,linspace(start,stop,length(val))];

    end
    
    %setup sphere
    r = S2Grid(sph2vec(current_theta(:), current_rho(:)),'antipodal');
    
    %add polefigure
    pf(i+1) = PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:});
    
  end
  
else
  error('Format XRDML does not match file %s.',fname);
end



