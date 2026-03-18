% test funcitonalities of SO3FunMLS class for various settings, 
% as well as the interaction with other classes in all those settings

%% options
% symmetries
cs = crystalSymmetry('1');
ss = specimenSymmetry('1');

%% approximate real function, complex function, vector-valued function from
%   values on random nodes
% at the same time this tests proper handling of arrays of S2FunMLS

k = 6;

% test functions
% f(1) = SO3FunHarmonic.example; 
% cs = f(1).CS; ss = f(1).SS;
% f(2) = complex(0,1) * f(1) - f(1).^2;
% f(3) = SO3FunHarmonic(2 * rand(64, 1, 1) - 1, cs, ss);
f(1:k) = SO3FunHarmonic(2 * rand(32, 1, k) - 1, cs, ss);
f = reshape(f, 3, 1, 2);
% for i = 1 : numel(f)
%   f(i) = SO3FunHarmonic(@(ori)(real(f(i).eval(ori))));
% end
myplot(f, 1);

% grid for the test function, values on the grid
N = 1e4;
ori = orientation.rand(1, N, 2);
f_values = f.eval(ori);

% test nodes
ori2 = orientation.rand(1e4);


%% test with standard parameters only
SO3F = SO3FunMLS(ori, f_values, cs, ss);
% SO3F.detectOutliers = true;
% SO3F.outlierDetectionRange = 5;

% for i = 1 : numel(f)
%   figure(1); plot(f(i)); colorbar;
%   figure(2); plot(SO3F(i)); colorbar; 
%   figure(3); plot(SO3F(i) - f(i)); colorbar;
%   waitforbuttonpress();
% end

myplot(f(2,1), 1);

diff = SO3F - f;
disp(max(abs(diff.eval(ori2))));
myplot(SO3F(2,1), 2);

%% same test, but with range search instead of knn search
SO3F.delta = SO3F.compute_delta();
myplot(f, 1);
myplot(SO3F, 2);
diff = SO3F - f;
disp(max(abs(diff.eval(ori))));
SO3F.delta = 0;

%% test various parameter settings for the same test function
ori2 = orientation.rand(1e2);
% f = SO3FunHarmonic(2 * rand(64, 1) - 1);
f = @(ori)(sin(ori.a.^2) .* cos(ori.b) - exp(ori.c.^2) .* ori.d.^2);
f = SO3FunHarmonic.quadrature(f);
f = @(ori)(real(f.eval(ori)));
f = SO3FunHarmonic(f);
f_values = f.eval(ori);

opts = {'centered'; 'monomials'; 'tangent'; 'regularize'};
numopts = numel(opts);
truefalse_idx = 2 * (1 : numopts)';
opt_idx = truefalse_idx - 1;
marker = logical(dec2bin((0 : 2^numopts-1)') - '0');

flag_template = cell(2*numopts, 1);
flag_template(opt_idx) = opts(1 : numopts)';

extra_flags = {'detectOutliers'; 'subsample'};
extra_marker = zeros(size(extra_flags));
num_extra_flags = numel(extra_flags);
mls_values = zeros(numel(ori2), 2^numopts * 2^num_extra_flags);
mls_conds = zeros(numel(ori2), 2^numopts * 2^num_extra_flags);
clear SO3F;
SO3F = cell(2^numopts * 2^num_extra_flags, 1);

for i = 1 : numel(SO3F)

  marker_idx = mod(i-1, 2^numopts) + 1;
  truefalse = num2cell(marker(marker_idx,:), 1);
  flag_template(truefalse_idx) = truefalse;

  for j = 1 : numel(extra_flags)
    extra_marker(j) = logical(mod(floor((i-1) / 2^(numopts+j-1)), 2));
    extra_marker(j) = logical(mod(floor((i-1) / 2^(numopts+j-1)), 2));
  end

  current_flags = [flag_template; extra_flags(extra_marker > 0)];
  SO3F{i} = SO3FunMLS(ori, f_values, current_flags{:});
  % S2F{i}.delta = 0;
  % S2F{i}.delta = S2F{i}.compute_delta() * 1;
  [mls_values(:,i), mls_conds(:,i)] = SO3F{i}.eval(ori2);
  % disp(i / numel(S2F) * 100);
  disp(i);
  disp(current_flags);
end

errors = abs(mls_values - f.eval(ori2));
errors(:, [2, 6, 10, 14]) = 0;
disp('maximal errors: ');
disp(max(errors, [], 1));
disp('maximal condition numbers: ');
disp(max(mls_conds, [], 1));

%% test outlier detection 
num_outliers = round(numel(ori) * .01);
I = randperm(numel(ori), num_outliers);
noisy_values = f_values;
noisy_values(I) = 1 * mean(abs(f_values(:))) * (2 * rand(num_outliers, 1) - 1);

% MLS without outlier detection
SO3F = SO3FunMLS(ori, noisy_values);
myplot(f, 1);
myplot(SO3F, 2);

% MLS with outlier detection
SO3F2 = SO3FunMLS(ori, noisy_values);
SO3F2.detectOutliers = true;
SO3F2.outlierDetectionRange = 25;
myplot(SO3F2, 3);

%% test outlier detection with range search

% MLS without outlier detection
SO3F = SO3FunMLS(ori, noisy_values);
SO3F.delta = SO3F.compute_delta();

myplot(f, 1);
myplot(SO3F, 2);

% MLS with outlier detection
SO3F2 = SO3FunMLS(ori, noisy_values);
SO3F2.detectOutliers = true;
SO3F2.outlierDetectionRange = round(SO3F2.dim * .7);
SO3F.delta = SO3F.compute_delta() * 1;

myplot(SO3F2, 3);

%% helper functions, mainly for plotting

function myplot(fun, fignum)
  figure(fignum);
  plot(fun); 
  colormap(WhiteJetColorMap);
  mtexColorbar;
end