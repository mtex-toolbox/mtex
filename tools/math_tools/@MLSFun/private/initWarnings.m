function warnings = initWarnings
% neighborhood warning flags, all cleared

warnings = struct('rangeTooFew',false,'rangeTooMany',false, ...
  'smoothTooFew',false,'smoothAllCandidates',false);

end
