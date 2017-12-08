function cS =repmat(cS,n)


s.Vertices = cat(1,v{:});

shift = length(v{1}) * repmat((0:length(grains)-1),size(s.Faces,1),1);
shift = repmat(shift(:),1,size(s.Faces,2));

s.Faces = repmat(s.Faces,length(grains),1) + shift;

end