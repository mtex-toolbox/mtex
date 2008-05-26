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
% interfaces_index

try
  doc = xmlread(fname);
catch
  error('file not found or format xrdml does not match file %s',fname);
end


xRoot = doc.getDocumentElement;

if strcmp(xRoot.getTagName,'xrdMeasurements')
    %begin import
  nodelist = xRoot.getElementsByTagName('xrdMeasurement');
  pf = [];
    
    %loop over measurements
  for i=0:nodelist.getLength-1
    d=[];
    current_theta = [];
    current_rho = [];
    
      %read current measurement
    xrdMeasurement = nodelist.item(i);
    scan = xrdMeasurement.getElementsByTagName('scan');  
    
      %read hkl from first entry
    hkl_node = scan.item(0).getElementsByTagName('hkl').item(0).getChildNodes; hkl = ['hkl']; h_ =[];
    for k=1:3, h_ = [h_, ...
      str2num(hkl_node.getElementsByTagName(hkl(k)).item(0).getFirstChild.getNodeValue)];  end 
    h = Miller(h_(1),h_(2),h_(3));
    
    step_axis = xrdMeasurement.getAttribute('measurementStepAxis');

      %loop over all scan-data sets
    for i=0:scan.getLength-1      
      val = str2num(scan.item(i).getElementsByTagName('intensities').item(0).getFirstChild.getNodeValue);
      d = [d,val];
     
        %get start and stop position
      pos = scan.item(i).getElementsByTagName('positions');
      rot_start = scan.item(i).getElementsByTagName('startPosition').item(0);
      	%check units
      if strcmp(rot_start.getParentNode.getAttribute('unit'),'deg')
        isrho_deg=degree; 
      else, isrho_deg=1; end; 
      start = str2num(rot_start.getFirstChild.getNodeValue);
      stop = str2num(scan.item(i).getElementsByTagName('endPosition').item(0).getFirstChild.getNodeValue);
     
        %get theta
      for k=0:pos.getLength-1
        if strcmp(pos.item(k).getAttribute('axis'), char(step_axis))
            %check units
          if strcmp(pos.item(k).getAttribute('unit'),'deg')
            istheta_deg=degree;
          else, istheta_deg=1; end;   
            %get theta
          theta = str2double(pos.item(k).getElementsByTagName('commonPosition').item(0).getFirstChild.getNodeValue);
          current_theta = [ current_theta; ...
            ones(length(val),1)*istheta_deg*theta];
        end
      end
      
        %get rho, mode="Continuous"
      step = abs(start-stop)/(length(val)-1);
      for k=0:length(val)-1
        current_rho = [ current_rho; (start+k*step)*isrho_deg ];
      end      
    end
    
      %setup sphere 
    r = S2Grid(sph2vec(current_theta, current_rho),'hemisphere')
      %add polefigure
    pf = [pf,PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:})]
  end
else
  error('format xrdml does not match file %s',fname);
end



