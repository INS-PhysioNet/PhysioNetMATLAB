function pvals = MCpValue(x,p,alternative)
% MCpValue Gget corresponding percentiles (in [0,1]) of values p in data x
%
% arguments:
%     x              char, path to text file, where each line contains the path to a session's xml file and optional arguments and comments (see usage)
%     p              observed values
%     alternative    string = 'two-sided', can also be "greater" or "less", test direction, either:
%                      - 'two-sided':  two tailed test
%                      - 'greater':    test the null hypothesis that observed values are smaller than surrogate
%                      - 'less':       test the null hypothesis that observed values are greater than surrogate

% alternative "greater": high p-value if x bigger than p -> H0: x is bigger than p

arguments
  x (:,:) % n_observation, n_data_sets
  p (:,:) % n_values, n_data_sets
  alternative (1,1) string {mustBeMember(alternative,["two-sided","greater","less"])} = "two-sided"
end

if size(x,2) ~= size(p,2)
  error('MCpValue:inputSize','''x'' and ''p'' must have the same number of columns')
end

count = zeros(size(p)); % number of observations supporting the null hypothesis for every value of p

if alternative == "greater"
  for i = 1 : size(x,2)
    count(:,i) = sum(x(:,i).' >= p(:,i),2);
  end
elseif alternative == "less"
  for i = 1 : size(x,2)
    count(:,i) = sum(x(:,i).' <= p(:,i),2);
  end
else
  for i = 1 : size(x,2)
    greater = sum(x(:,i).' >= p(:,i),2);
    less = sum(x(:,i).' <= p(:,i),2);
    count(:,i) = 2 * min(greater,less);
  end
end

pvals = (count + 1) / (size(x,1) + 1); % +1 implement finite-sample Monte Carlo correction
pvals = min(pvals,1); % cap maximum possible p-value at 1