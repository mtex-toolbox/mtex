function ebsd = reshape(ebsd,varargin)
% reshape

% pos belongs in here as much as id and rotations do - @EBSDgrid states the
% invariant that id, rotations, pos and every prop are (r × c). Leaving pos
% behind made subGrid hand back an @EBSDsquare whose pos was still a column,
% so ebsd.d2 read pos(1,2) and errored while ebsd.d1 quietly returned the
% right number for the wrong reason. The @EBSDsquare constructor reshapes
% before it has built pos, so an empty one is left alone rather than
% erroring on the element count.
if ~isempty(ebsd.pos), ebsd.pos = reshape(ebsd.pos,varargin{:}); end
ebsd.rotations = reshape(ebsd.rotations,varargin{:});
ebsd.id = reshape(ebsd.id,varargin{:});


% A multi channel property keeps its channels: what is being reshaped is the
% object's own shape, and the channel dimension rides along behind it - n × k
% for a column shaped object, r × c × k for a grid. Without this a 3 channel
% image on a map came out of subGrid holding channel 1 only, silently.
sz = [varargin{:}];
base = sz;
if numel(base) == 2 && base(2) == 1, base = base(1); end

n = length(ebsd);

for fn = fieldnames(ebsd.prop).'

  v = ebsd.prop.(char(fn));
  k = numel(v) / n;

  if n > 0 && k > 1 && k == round(k)
    ebsd.prop.(char(fn)) = reshape(v,[base k]);
  else
    ebsd.prop.(char(fn)) = reshape(v,sz);
  end

end


end