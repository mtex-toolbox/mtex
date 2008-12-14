function nobj = horzcat(varargin)

nobj = EBSD();
for i=1:length(varargin)
  if ~isempty(varargin{i})
    nobj.comment = varargin{i}.comment;
    
    nobj.orientations = [nobj.orientations varargin{i}.orientations];
    nobj.xy = [nobj.xy; varargin{i}.xy];
    nobj.phase = [nobj.phase(:); varargin{i}.phase(:)];
    nobj.grainid = [nobj.grainid; varargin{i}.grainid];
    
    vname = fields(varargin{i}.options);
    
    for k=1:length(vname)
      if isempty(fields(nobj.options))
        str = cellfun(@(x) {x {}},vname,'uniformoutput',false);
        str = [str{:}];
        nobj.options = struct(str{:});
      end 
      nobj.options(1).(vname{k}) = [nobj.options.(vname{k}); varargin{i}.options.(vname{k})];
    end
  end
end


