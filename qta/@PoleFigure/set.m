function pf = set(pf,vname,value,varargin)
% set polefigure properties to a specific value 
%
%% Syntax
% pf = set(pf,'intensities',data,id)
% pf = set(pf,'CS',cs) 
% pf = set(pf,'h',h)
%
%% Input
%  pf   - @PoleFigure
%  data - [double] 
%  id   - index set (optional)
%
%% Output
%  pf - @PoleFigure
%
%% See also
% PoleFigure/get PoleFigure/delete PoleFigure/copy

switch vname
  
  case {'data','intensities'}
    
    cs = cumsum([0,GridLength(pf)]);
    if nargin == 4
      id = varargin{1};
      if isa(id,'logical'), id = find(id);end

      for i= 1:length(pf)
        ipf = (id > cs(i)) & (id<=cs(i+1));
        
        if numel(value) > 1
          pf(i).data(id(ipf)-cs(i)) = value(ipf);
        else
          pf(i).data(id(ipf)-cs(i)) = value;
        end
      end
  
    else
  
      for i = 1:length(pf)
        pf(i).data = value(min(numel(value),cs(i)+1:cs(i+1)));
      end
  
    end

  otherwise
  
    for i = 1:numel(pf)
  
      % is value is a cell spread it over all elements of pf
      if iscell(value) && length(value) == length(pf)
        ivalue = value{i};
      elseif iscell(value)
        ivalue = value{i};
      else
        ivalue = value;
      end
  
      switch vname
        case 'CS'
          pf(i).h = set(pf(i).h,'CS',ivalue);
        case 'h'
          if numel(ivalue) ~= numel(pf(i).c)
            pf(i).c = ones(size(ivalue)) ./ numel(ivalue);
          end
      end
          pf(i).(vname) = ivalue;
      end
    end
      
end
