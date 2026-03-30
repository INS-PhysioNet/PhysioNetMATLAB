function [p,h] = maxStatisticTest(data,surrogate,statistic,opt)
% maxStatisticTest Conduct a max statistic test over time

% alternative "greater": high p-value if surrogate stat is bigger than real -> H0: surrogate statistic is bigger than real, so take max for every surr

arguments
  data (:,:) % n sessions, n times
  surrogate (:,:,:) % n session, n times, n surrogates
  statistic function_handle = @(x) mean(x,'omitmissing')
  opt.alpha (1,1) {mustBePositive} = 0.05
  opt.alternative (1,1) string {mustBeMember(opt.alternative,["two-sided","greater","less"])} = "two-sided"
end

% validate input
if size(data,1) ~= size(surrogate,1) || size(data,2) ~= size(surrogate,2)
  error('maxStatisticTest:inputSize','Arguments ''data'' and ''surrogate'' must have the same number of rows and columns')
end

n_times = size(data,2);
n_surrogates = size(surrogate,3);

% statistic for real and surrogate data
s_real = statistic(data); % (1,n_times)
s_surrogate = zeros(n_times,n_surrogates); % (n_times,n_surrogates)
for i = 1 : n_surrogates
  s_surrogate(:,i) = statistic(surrogate(:,:,i));
end

% p-values per time point
if opt.alternative == "greater"
  s_surrogate = min(s_surrogate,[],1).'; % (n_surrogates,1)
  p = MCpValue(repmat(s_surrogate,1,n_times),s_real,opt.alternative); % (n_times,1)

elseif opt.alternative == "less"
  s_surrogate = max(s_surrogate,[],1).';
  p = MCpValue(repmat(s_surrogate,1,n_times),s_real,opt.alternative);

else
  % standardize statistic to ensure proper two-tailed test
  mu = mean(s_surrogate,2); % (n_times,1)
  sigma = std(s_surrogate,0,2);
  s_real = abs((s_real - mu.') ./ sigma.'); % abs(z-score( ))
  s_surrogate = (s_surrogate - mu) ./ sigma;
  s_surrogate = max(abs(s_surrogate),[],1).'; % max_t(abs(z-score( ))), i.e., (n_surrogates,1)
  p = MCpValue(repmat(s_surrogate,1,n_times),s_real,"greater");
  
end

h = p < opt.alpha;

end