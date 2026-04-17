function pvals = MCpValue(x,p,alternative)
% MCpValue Get corresponding percentiles (in [0,1]) of values p in data x
%
% arguments:
%     x              (n,m), surrogate data, n: n. surrogate replicates, m: n. independent data sets
%     p              (l,m), observed values, l: n. values to test, m: same as above
%     alternative    string = 'two-sided', test direction, either:
%                      - 'two-sided':  two tailed test
%                      - 'greater':    test the null hypothesis that observed values are smaller than surrogate
%                      - 'less':       test the null hypothesis that observed values are greater than surrogate
%
% output:
%     pvals          (l,m), p-values associated to each element of p
%
% notes:
%     1. the function is vectorized as if results were computed separately per each element of 'p'
%     2. elements in the same column of 'p' are separately tested against the same column of 'x'
%     3. alternative 'greater' gives high p-values if 'x' is bigger than 'p' -> H0: x is bigger than p

arguments
  x (:,:)
  p (:,:)
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