function obj = partition(ebsd, id,varargin)
% reorganize EBSD data into sets
%
%% Syntax
%  ebsd_parts = partition(ebsd,id) - splits the EBSD into parts specified by an
%  id--vector, mainly for internal usage (@grain)
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

for k=1:numel(ebsd)
  if csz(k+1) - csz(k) > 0
    
    ind = id(csz(k)+1:csz(k+1));

    [ids ndx] = sort(ind);
    pos = [0 ;find(diff(ids)); numel(ind)];
    aind = ids(pos(1:end-1)+1);  
    holdit(aind) = true;
  
    if ~check_option(varargin,'fields')
      obj(aind) = ebsd(k);

      %presort
      o = ebsd(k).orientations(ndx);

      if ~isempty(ebsd(k).X), do_xy = true;
        xy = ebsd(k).X(ndx,:);
      else do_xy = false; end
      
      
      do_options = ~check_option(varargin,'nooptions');
      if do_options, options = partition(ebsd(k),ind,'fields'); end
      
      op = partition(o,pos);
      
      for l=1:numel(pos)-1
        obj(aind(l)).orientations = op{l};

        if do_xy, obj(aind(l)).X = xy(pos(l)+1:pos(l+1),:); end
        if do_options, obj(aind(l)).options = options(l); end        
      end
    else
      % do options
      options = ebsd(k).options;
      vname = fields(options);
      
      nfld = numel(vname);
      fld = cell(1,nfld*2);
      fld(1:2:nfld*2) = vname(1:nfld);
      
      for l=1:length(vname)
        prt = cell(numel(aind),1);
        
        if numel(options.(vname{l})) == numel(ndx)
          data = options.(vname{l})(ndx,:);          
          
          for j=1:numel(pos)-1
            ind = pos(j)+1:pos(j+1);
            prt{j} =  data(ind,:);
          end
        else
          prt{aind(j)} = options.(vname{l});
        end
        
        fld{2*l} = prt;
      end
      
      obj(aind) = struct(fld{:})';
      
    end
  end
end

obj = obj(holdit);