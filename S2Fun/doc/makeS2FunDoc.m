function makeS2FunDoc

list = {'doc_index', 'doc_S2FunHarmonic', 'doc_S2FunHarmonicSym', 'doc_S2VectorFieldHarmonic', 'doc_S2AxisFieldHarmonic'};

for j = 1:length(list)
  publish(list{j}, 'maxHeight', 300)
end

end
