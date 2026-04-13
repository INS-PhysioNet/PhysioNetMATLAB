function stats = clusterBasedPerm(data1, data2, varargin)
%
% Performs a cluster-based permutation test to compare two groups of data
% (eg, peth wake vs peth sleep), accounting for temporal correlation.
%
% INPUTS:
%   data1   - [nCells x nTime] matrix (e.g., z-scored PETH wake)
%   data2   - [nCells x nTime] matrix (e.g., z-scored PETH sleep)
%
% OPTIONAL (name-value pairs):
%   'paired'   - true/false (default: true)
%   'nperm'    - number of permutations (default: 1000)
%   'alpha'    - significance level (default: 0.05)
%   'tail'     - 'both', 'right', 'left' (default: 'both')
%   'clusterstat' - 'size'(default) or 'mass'
%   'statistic'- func handle (default:@(x) mean(x,1,'omitnan') ./ (std(x,0,1,'omitnan') ./ sqrt(sum(~isnan(x),1)))
%
% OUTPUT:
%   stats structure containing:
%       .stat           - observed statistic (time series)
%       .clusters       - cluster labels
%       .cluster_stat   - observed cluster masses
%       .p_cluster      - p-values for each cluster
%       .sig_mask       - logical mask of significant timepoints (eg, to plot significant windows)
%
% NOTES:
% - Uses cluster-mass/size statistic (sum of stats within/length of cluster)
% - Ok for temporally correlated data

%% ------------------ Parse inputs ------------------

p = inputParser;

addRequired(p, 'data1');
addRequired(p, 'data2');

addParameter(p, 'paired', false);
addParameter(p, 'nperm', 1000);
addParameter(p, 'alpha', 0.05);
addParameter(p, 'tail', 'both');
addParameter(p, 'clusterstat', 'size'); % 'mass' or 'size'
addParameter(p, 'statistic', []); % t-stats

parse(p, data1, data2, varargin{:});
opt = p.Results;

%% ------------------ Basic checks ------------------
[n1, T] = size(data1);
[n2, T2] = size(data2);

if T ~= T2
    error('x dim must match between groups');
end

if opt.paired && n1 ~= n2
    error('Paired test: non consistent numb or rows');
end

%% ------------- Compute observed stat (ttest) ------------------

if opt.paired
    diff_data = data1 - data2;
    n         = sum(~isnan(diff_data), 1);        
    mu        = mean(diff_data, 1, 'omitnan');
    sigma     = std(diff_data,  0, 1, 'omitnan');
    stat      = mu ./ (sigma ./ sqrt(n));         
    df        = n - 1;  
else
    n1t  = sum(~isnan(data1), 1);
    n2t  = sum(~isnan(data2), 1);
    mu1  = mean(data1, 1, 'omitnan');
    mu2  = mean(data2, 1, 'omitnan');
    s1   = std(data1,  0, 1, 'omitnan');
    s2   = std(data2,  0, 1, 'omitnan');
    % Pooled two-sample t
    sp   = sqrt(((n1t-1).*s1.^2 + (n2t-1).*s2.^2) ./ (n1t+n2t-2));
    stat = (mu1 - mu2) ./ (sp .* sqrt(1./n1t + 1./n2t));
    df   = n1t + n2t - 2;  
end

% ------------------ Threshold for clustering ------------------
switch opt.tail
    case 'both'
        thresh = tinv(1 - opt.alpha/2, df);
        sig = abs(stat) > thresh;
    case 'right'
        thresh = tinv(1 - opt.alpha, df);
        sig = stat > thresh;
    case 'left'
        thresh = tinv(1 - opt.alpha, df);
        sig = stat < -thresh;
end

%% ------------------ Find clusters ------------------
clusters = bwlabel(sig);
nClusters = max(clusters);

cluster_stat = zeros(1, nClusters);

for c = 1:nClusters
    idx = clusters == c;
    switch opt.clusterstat
        case 'mass'
            cluster_stat(c) = sum(abs(stat(idx)));
        case 'size'
            cluster_stat(c) = sum(idx); % number of timepoints
    end
end

%% ------------------ Permutation testing ------------------
% comparison btw permutation and data can be done either with cluster size
% (ok for highly skewed data when mass can be driven by a few extreme values 
% OR with cluster mass (linked both to size and to effect magnitude)

nperm = opt.nperm;
max_cluster_perm = zeros(nperm,1);

if opt.paired
    % sign-flip permutation
    for p_i = 1:nperm
        signs     = (rand(n1,1) > 0.5)*2 - 1;
        perm_data = diff_data .* signs;
        
        % t-stat (not mean) for permuted data
        mu_p    = mean(perm_data, 1, 'omitnan');
        sig_p   = std(perm_data,  0, 1, 'omitnan');
        n_p     = sum(~isnan(perm_data), 1);
        stat_perm = mu_p ./ (sig_p ./ sqrt(n_p));

        switch opt.tail
            case 'both'
                sig_perm = abs(stat_perm) > thresh;
            case 'right'
                sig_perm = stat_perm > thresh;
            case 'left'
                sig_perm = stat_perm < -thresh;
        end

        clust_perm = bwlabel(sig_perm);
        
        max_mass = 0;
        for c = 1:max(clust_perm)
             idx = clust_perm == c;
            switch opt.clusterstat
                case 'mass'
                    mass = sum(abs(stat_perm(idx)));
                case 'size'
                    mass = sum(idx);
            end
            if mass > max_mass
                max_mass = mass;
            end
        end
        max_cluster_perm(p_i) = max_mass;
    end
else
   for p_i = 1:nperm
    
    combined = [data1; data2];
    labels = [ones(n1,1); zeros(n2,1)];
    % label-shuffle permutation
    
    perm_idx = randperm(length(labels));
    perm_labels = labels(perm_idx);
    
    grp1 = combined(perm_labels==1,:);
    grp2 = combined(perm_labels==0,:);
    
    % Two-sample t-stat for permuted groups
    mu1_p  = mean(grp1, 1, 'omitnan');
    mu2_p  = mean(grp2, 1, 'omitnan');
    s1_p   = std(grp1,  0, 1, 'omitnan');
    s2_p   = std(grp2,  0, 1, 'omitnan');
    n1_p   = sum(~isnan(grp1), 1);
    n2_p   = sum(~isnan(grp2), 1);
    
    % Pooled two-sample t
    sp_p      = sqrt(((n1_p-1).*s1_p.^2 + (n2_p-1).*s2_p.^2) ./ (n1_p+n2_p-2));
    stat_perm = (mu1_p - mu2_p) ./ (sp_p .* sqrt(1./n1_p + 1./n2_p));
    
    switch opt.tail
        case 'both'
            sig_perm  = abs(stat_perm) > thresh;
        case 'right'
            sig_perm  = stat_perm > thresh;
        case 'left'
            sig_perm  = stat_perm < -thresh;
    end

    clust_perm = bwlabel(sig_perm);
    
    max_mass = 0;
    for c = 1:max(clust_perm)
        idx = clust_perm == c;
        switch opt.clusterstat
            case 'mass'
                mass = sum(abs(stat_perm(idx)));
            case 'size'
                mass = sum(idx);
        end
        if mass > max_mass
            max_mass = mass;
        end
    end
    max_cluster_perm(p_i) = max_mass;
   end
end

%% ------------------ Compute p-values ------------------
p_cluster = ones(1, nClusters);

for c = 1:nClusters
    p_cluster(c) = mean(max_cluster_perm >= cluster_stat(c));
end

%% ------------------ Significant mask ------------------
sig_mask = false(1, T);

for c = 1:nClusters
    if p_cluster(c) < opt.alpha
        sig_mask(clusters == c) = true;
    end
end

%% ------------------ Output ------------------
stats.stat = stat;
stats.clusters = clusters;
stats.cluster_stat = cluster_stat;
stats.p_cluster = p_cluster;
stats.sig_mask = sig_mask;
stats.threshold = thresh;

end
