function varargout = boxPlot(data,group,opt)
% plotDistr Plot boxplot of data
%
%  arguments
%     data       (n,c), columns define different data vectors, plotted as boxplots of different colors
%     group      (n,1), second grouping variable, defines multiple sets of boxplot, each centered on a value of 'group'
%
% name-value arguments
%     reverse    logical = false, reverse roles of columns in 'data' and 'group': the former defines boxplot sets, the latter colors
%     legend     (:,1) string = [], legend labels, one for each color
%     label      (:,1) string = [], x axis labels, one for each group or, for a signle group, one for each color
%     color      (:,3) = [], RGB color matrix, each row defines a color
%     ax         axis = gca, axes to plot in
%
% output
%     b          (1,c) BoxChart
%     infp       struct, having fields:
%     - lw, q1, q2, q3, uw    (n_groups,n_colors) double, lower whisker, quantiles and upper whisker values, respectively, per boxplot
%     - ol                    {n_groups,n_colors} cell of logical, mask identifying outliers per boxplot (NaNs are flagged as false)

arguments
  data (:,:) {mustBeNumeric}
  group (:,1) = ones(size(data,1),1)
  opt.reverse (1,1) {mustBeLogical} = false
  opt.legend (:,1) string = string.empty
  opt.label (:,1) string = string.empty
  opt.color (:,3) {mustBeNumeric,mustBeNonnegative,mustBeLessThanOrEqual(opt.color,1)} = []
  opt.ax (1,1) matlab.graphics.axis.Axes = gca
end

if numel(group) ~= size(data,1)
  error('boxPlot:groupSize',"'group' must have one element for every row of 'data'")
end

group = repmat(group,size(data,2),1); % identifies set of boxplots
c_group = repelem((1:size(data,2)).',size(data,1)); % identifies color
if opt.reverse
  [group,c_group] = deal(c_group,group);
end

n_groups = numel(unique(group));
n_colors = numel(unique(c_group));
if n_groups == 1
  if ~ismember(numel(opt.label),[0,n_groups,n_colors])
    error('boxPlot:labelSize',"'label' must have one element for every color group or set of boxplots")
  end
else
  if ~ismember(numel(opt.label),[0,n_groups])
    error('boxPlot:labelSize',"'label' must have one element for every set of boxplots")
  end
end

if ~ismember(size(opt.color,1),[0,n_colors])
  error('boxPlot:colorSize',"'color' must have one row for every color group")
end
if ~ismember(numel(opt.legend),[0,n_colors])
  error('boxPlot:groupSize',"'legend' must have one element for every color group")
end

data = data(:);
if n_groups == 1 && n_colors > 1
  % special case: one box for every color, we can directly control x coordinates
  hold on
  unique_cgroups = unique(c_group).';
  for i = 1 : numel(unique_cgroups)
    b(i) = boxchart(opt.ax,i*ones(sum(c_group==unique_cgroups(i)),1),data(c_group==unique_cgroups(i)),'MarkerStyle','.','MarkerColor','k');
  end
else
  b = boxchart(opt.ax,group,data,'GroupByColor',c_group,'MarkerStyle','.','MarkerColor','k');
end

if ~isempty(opt.label)
  if n_groups == 1 && numel(opt.label) == n_colors
    % special case: one x tick for every color
    xticks(arrayfun(@(x) x.XData(1), b))
  else
    xticks(unique(b(1).XData))
  end
  xticklabels(opt.label)
end
if ~isempty(opt.color)
  for i = 1 : numel(b)
    b(i).BoxFaceColor = opt.color(i,3);
  end
end
if ~isempty(opt.legend)
  for i = 1 : numel(b)
    b(i).DisplayName = opt.legend(i);
  end
end

varargout{1} = b;

if nargout > 1
  unique_groups = unique(group).';
  unique_cgroups = unique(c_group).';
  [varargout{2}.lw,varargout{2}.q1,varargout{2}.q2,varargout{2}.q3,varargout{2}.uw] = deal(nan(numel(unique_groups),numel(unique_cgroups)));
  varargout{2}.ol = cell(numel(unique_groups),numel(unique_cgroups));

  for i = 1 : numel(unique_groups)
    for j = 1 : numel(unique_cgroups)
      x = data(group == unique_groups(i) & c_group == unique_cgroups(j));
      q1 = prctile(x,25);
      q2 = prctile(x,50); % median
      q3 = prctile(x,75);
      iqr_val = q3 - q1; % interquartile range

      % Tukey fences
      lower_fence = q1 - 1.5 * iqr_val;
      upper_fence = q3 + 1.5 * iqr_val;

      % whiskers: most extreme data within fences
      lw = min(x(x >= lower_fence));
      if ~isempty(lw)
        varargout{2}.lw(i,j) = lw;
      end
      uw = max(x(x <= upper_fence));
      if ~isempty(uw)
        varargout{2}.uw(i,j) = uw;
      end
      varargout{2}.q1(i,j) = q1;
      varargout{2}.q2(i,j) = q2;
      varargout{2}.q3(i,j) = q3;

      % outliers: values outside fences
      varargout{2}.ol{i,j} = (x < lower_fence) | (x > upper_fence);
      
    end
  end
end