%% Bingham statistics for single grains
% 
%% Plotting

h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1),Miller(1,1,3)];

plotPDF(ebsd,h,'antipodal');

%% Mean orientation and orientation tensor

[q_mean, lambda, EV, kappa] = mean(ebsd);

% some output
Euler(symmetrise(q_mean))

fprintf('    lambda    kappa\n')
fprintf(' %.7f  %7.2f\n',[lambda kappa]')

%% Bingham Model

odf_model = BinghamODF(kappa,EV,CS,SS);

plotPDF(odf_model,h,'antipodal','resolution',5*degree);
annotate(q_mean);

%%

plot(odf_model,'sigma','sections',9);


%% Testing on distribution by parameters

T_spherical = bingham_test(ebsd,'spherical')
T_prolate   = bingham_test(ebsd,'prolatnes')
T_oblate    = bingham_test(ebsd,'oblatnes')

%% Testing on distribution by second moments

T_spherical_c = bingham_test(ebsd,'spherical','chat')
T_prolate_c   = bingham_test(ebsd,'prolatnes','chat')
T_oblate_c    = bingham_test(ebsd,'oblatnes','chat')
   
% some output

fprintf('p-spherical : %2.5f\t%2.5f\n', T_spherical ,T_spherical_c)
fprintf('p-prolate   : %2.5f\t%2.5f\n', T_prolate   ,T_prolate_c)
fprintf('p-oblate    : %2.5f\t%2.5f\n', T_oblate    ,T_oblate_c)

%% Variing the size of samples (parameters)

[qm lambda EV kappa] = mean(ebsd);
nto = sampleSize(ebsd);

hold on, 
plot(bingham_test(1:nto,kappa,lambda,'spherical'),'b')
plot(bingham_test(1:nto,kappa,lambda,'prolatnes'),'g')
plot(bingham_test(1:nto,kappa,lambda,'oblatnes'),'r')

legend('spherical','prolatnes','oblatnes')

%% Variing the size of samples (second moments)

[chat,lambda,EV,nto] = c_hat(ebsd);

hold on, 
plot(bingham_test(1:nto,chat,lambda,'spherical','chat'),'b')
plot(bingham_test(1:nto,chat,lambda,'prolatnes','chat'),'g')
plot(bingham_test(1:nto,chat,lambda,'oblatnes','chat'),'r')

legend('spherical','prolatnes','oblatnes')

%% Simulation

for resolutions = [5 2.5 1.5] *degree
  ebsd_sim = calcEBSD(odf_model,nto,'resolution',resolutions);

  [q_mean_sim lambda_sim EV_sim kappa_sim] = mean(ebsd_sim);
  
  % some output
  fprintf('kappa at resolution %2.2f:\n', resolutions/degree)
  fprintf('    true   simulated\n')
  fprintf(' %7.2f     %7.2f\n', [kappa,  kappa_sim]')
end

plotPDF(ebsd_sim,h,'antipodal')

%% Non-parametric model

odf_recalc = calcODF(ebsd);

plotPDF(odf_recalc,h,'antipodal');

%% compare it to parametric model

plotDiff(odf_model,odf_recalc,'sections',9)

%% Texture properties
% compare texture index of both odfs

for resolutions = [5 2.5 1.5] *degree
    
  t_index = [ textureindex(odf_model,'resolution',resolutions) ...
              textureindex(odf_recalc,'resolution',resolutions) ];
  % some output          
  fprintf('textureindex at resolution %2.2f:     %5.3f    %5.3f\n',...
    resolutions/degree, t_index)
end

%% Volume portion around mean
% variing radius arond mode 

for radius = [1.25 2.5 5 10 15] *degree
    fprintf('                                                 bingham | non-parametric\n')
  for resolutions = [5 2.5 1.25] *degree

    vol = [ volume(odf_model,  q_mean,radius,'resolution',resolutions) ...
            volume(odf_recalc, q_mean,radius,'resolution',resolutions) ];
    % some output          
    fprintf('volume portion at resolution %2.2f radius %5.2f:   %5.3f  |  %5.3f\n',...
      resolutions/degree, radius/degree, vol)
  end
end


%% Mode orientation from ODF
% actually the mode of the model odf should be the mean orientation

q_mode_model  = max(odf_model,'resolution',5*degree)
q_mode_recalc = max(odf_recalc,'resolution',5*degree)

angle(q_mean,q_mode_model)/degree
angle(q_mean,q_mode_recalc)/degree


