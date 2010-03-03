function obj = partition(ebsd, id,varargin)
% reorganize EBSD data into sets
%
%% Syntax
%  g = partition(ebsd,id)
%
%% Input
%  ebsd  - @EBSD
%  id    - index set
%
%% Output
%  obj     - @EBSD
%
%% Options
%  UniformOutput - true/false
%
%% Flag
%  nooptions - do not copy additional options
%  field     - apply only on specified field
%
%% See also
% grain/grainfun

csz = cumsum([0 sampleSize(ebsd)]);
holdit = false(1,sum(diff(sort(id))+1));

if ~check_option(varargin,'fields')
  
  topt = struct;
  dooptions = ~check_option(varargin,'nooptions');
  for k=1:numel(ebsd)
    ind = id(csz(k)+1:csz(k+1));
    
    [ids ndx] = sort(ind);
    aind = unique(ind)';
    sec = histc(ids,aind)';
    css = cumsum([0 sec]);
     
    o = ebsd(k).orientations(ndx);
     
    obj(aind) = repmat(ebsd(k) , size(aind));

    holdit(aind) = true;

  %presort
    if ~isempty(ebsd(k).xy), xy = ebsd(k).xy(ndx,:); end
    if dooptions
      ebsd_fields = fields(ebsd(k).options);
      rm = false(size(ebsd_fields));
      for f = 1:length(ebsd_fields)
        if length(ebsd(k).options.(ebsd_fields{f})) == length(ndx)
          opt.(ebsd_fields{f}) = ebsd(k).options.(ebsd_fields{f})(ndx,:);
        else
          opt2.(ebsd_fields{f}) = ebsd(k).options.(ebsd_fields{f});        
          rm(f) = true;
        end
      end
      ebsd_fields(rm) = [];
    end

  %copy information
    for l = 1:length(aind)
      ind = css(l)+1:css(l+1);
      obj(aind(l)).orientations = o(ind);
          
      if exist('xy','var'), obj(aind(l)).xy = xy(ind,:); end

      if dooptions
        for f = 1:length(ebsd_fields)
          opt2.(ebsd_fields{f}) = opt.(ebsd_fields{f})(ind,:);
        end
        obj(aind(l)).options = opt2;
      else
        obj(aind(l)).options = topt;
      end
    end
    
  end 
else
  eb_field = get_option(varargin,'fields','all');

  for k=1:numel(ebsd)
    ind = id(csz(k)+1:csz(k+1));  

    [ids ndx] = sort(ind);        
    aind = unique(ind)';
    holdit(aind) = true;
    
    sec = histc(ids,aind)';
    css = cumsum([0 sec]); 
  
    ebsd_fields = fields(ebsd(k).options);
    
    if ~strcmpi(eb_field,'all')
      pr = cellfun(@(x) any(strcmpi(x, eb_field)),ebsd_fields);
  
      if all(pr == 0)
        error('unknown option')
      end
    else
      pr = true(size(ebsd_fields));
    end
    
    ebsd_fields(~pr) = [];
    
    flds = cell(1,length(ebsd_fields)*2);
    flds(1:2:length(ebsd_fields)*2) = ebsd_fields(1:length(ebsd_fields));
    obj(aind) = struct(flds{:});
  
    rm = false(size(ebsd_fields));
    for f = 1:length(ebsd_fields)
      if length(ebsd(k).options.(ebsd_fields{f})) == length(ndx)
        opt.(ebsd_fields{f}) = ebsd(k).options.(ebsd_fields{f})(ndx,:);
      else
        opt2.(ebsd_fields{f}) = ebsd(k).options.(ebsd_fields{f});        
        rm(f) = true;
      end
    end
    ebsd_fields(rm) = [];
    
    for l = 1:length(aind)
      ind = css(l)+1:css(l+1);
      for f = 1:length(ebsd_fields)
        opt2.(ebsd_fields{f}) = opt.(ebsd_fields{f})(ind,:);
      end  
      obj(aind(l)) = opt2;
    end
  end
end

obj = obj(holdit); 


