function [m,inf,sup] = logConfidenceInterv(x,dim)
% logConfidenceInterv Get data's geometric mean and its 95% confidence interval
%
% arguments:
%     x           data, assumed to be approximatively log-normal
%     dim         int = 0, dimension of 'x' along which to operate, default is first non-singleton dimension
%
% output:
%     m           geometric mean of 'x' along dimension 'dim'
%     inf, sup    confidence interval bounds for 'm'

arguments
  x
  dim (1,1) = 0
end

% assign default value
if dim == 0
    dim = find(size(x) ~= 1,1);
end

x = log(x);
mu = mean(x,'omitnan');
m = exp(mu); % geometric mean
s = nansem(x);

coeff = tinv(0.975,size(x,dim)-1);
inf = exp(mu - coeff * s);
sup = exp(mu + coeff * s);