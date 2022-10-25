classdef neperInstance < handle

  properties

    morphology
    sphericity
    numGrains = 1000;
    iterMax = 10000;
    fileName = "run"
    
  end

methods

  function simulateGrains(this,ori)

    if isa(ori,'ODF')
      ori = ori.discreSample(this.numGrains);
    end
    
    % save ori to file 
    cprintf(ori.Euler ./ degree,'-fc','ori_in.txt','-q',true);

    system(['neper -T -n ' num2str(ngrains) ...
    ' -morpho "diameq:lognormal(1,0.35),1-:lognormal(0.145,0.03),aspratio(3,1.5,1)" ' ...
      ' -morphooptistop "itermax=1000" ' ... % decreasing the iterations makes things go a bit faster for testing
      ' -oricrysym "-1" -ori "file(ori_in.txt)" ' ...
      ' -statpoly faceeqs ' ... % some statistics on the faces
      ' -o allgrains ' ...
      ' -oridescriptor euler-bunge ' ...
      ' -oriformat plain ' ...
      ' -format tess,ori' ...
      ' && ' ...
      'neper -V allgrains.tess']);

  end

  function grains = getSlice(this,n)
    % 
    % Input
    %  n - slice normal
    %  

    % get a slice
    system(['neper -T -loadtess allgrains.tess ' ...
      '-transform "slice(1,1,1,1)" ' ... % this is (d,a,b,c) of a plane
      '-oricrysym "mmm" -ori "file(allgrains.ori)" ' ...
      '-o 2dslice ' ...
      '-oriformat geof ' ...
      '-oridescriptor quaternion ' ...
      '-format tess,ori ' ...
      '&& ' ...
      'neper -V 2dslice.tess']);

    grains = grain2d.load('2dslice.tess');

  end

end


methods (Static = true)

  function test

    neper = neperInstance;
    neper.morphology = '';
    neper.iterMax = 1000;

    neper.simulateGrains
    neper.getSlice

  end

end
end



