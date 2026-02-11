function h = holmBonferroni(p,alpha)
% holmBonferroni Perform Holm-Bonferroni correction for multiple comparisons
%
% arguments:
%     p        (n_tests,1) double, p-values associated to significance tests, NaN values are ignored
%     alpha    double, significance level
%
% output:
%     h        (n_tests,1) double, h(i) is:
%                - 1 if the null hypothesis of the i-th test is rejected
%                - NaN if p(i) is NaN
%                - 0 otherwise

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  p (:,1) {mustBeNumeric}
  alpha (1,1) {mustBeNumeric} = 0.05
end

% exclude NaNs
nan_ind = ~isnan(p);
p = p(nan_ind);

% sort the m p-values
[p,ind] = sort(p);
[~,reverse_ind] = sort(ind);

% find smallest p-value, p_k, such that:  p_k > alpha (m + 1 - k)
k = find(p > alpha ./ (numel(p) + 1 - (1:numel(p)).'),1);
if isempty(k)
  k = numel(p) + 1;
end

% reject null hypothesis {1, ..., k-1}
h_nan = zeros(size(p));
h_nan(1:k-1) = 1;
h_nan = h_nan(reverse_ind);

% reintroduce NaNs
h = nan(size(nan_ind));
h(nan_ind) = h_nan;