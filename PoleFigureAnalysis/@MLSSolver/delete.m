function delete(solver)

for i = 1:length(solver.nfft_gh)
  nfsftmex('finalize',solver.nfft_gh(i));
end

for i = 1:length(solver.nfft_r)
  nfsftmex('finalize',solver.nfft_r(i));
end

end