function plotDistr(data,opt)
% plotDistr Plot probability density function (pdf) of data
%
% repeating arguments
%     data        (:,1), data to draw distribution of, a curve is drawn for each 'data' provided
%
% name-value arguments
%     nbins       int = 0, number of bins to compute pdf, default is handled by <a href="matlab:help histcounts">histcounts</a>
%     polar       logical = false, make [0,2*pi] periodic edges for data in radians
%     log         logical = false, plot on loglog axis
%     label       (:,1) string = [], legend labels, one for each 'data'
%     color       (:,3), RGB color matrix, one for each 'data'
%     lineprop    (:,1) cell = {}, properties passed to <a href="matlab:help plot">plot</a>
%     name        string = "", name of the plotted quantity to make x axis label
%     unit        string = "", units of measurement of the plotted quantity to make x axis label
%     type        string = "pdf", passed to option 'Normalization' of <a href="matlab:help histcounts">histcounts</a>
%     ax          axis = gca, axes to plot in

arguments (Repeating)
  data (:,1) {mustBeNumeric}
end
arguments
  opt.nbins (1,1) {mustBeNumeric,mustBeInteger,mustBeNonnegative} = 0
  opt.polar (1,1) {mustBeLogical} = false
  opt.log (1,1) {mustBeLogical} = false
  opt.label (:,1) string = []
  opt.color (:,3) {mustBeNumeric,mustBeNonnegative,mustBeLessThanOrEqual(opt.color,1)} = myColors(1:numel(data))
  opt.lineprop (:,1) cell = {}
  opt.name (1,1) string = ""
  opt.unit (1,1) string = ""
  opt.type (1,1) string = "pdf"
  opt.ax (1,1) matlab.graphics.axis.Axes = gca
end

if ~isempty(opt.label) && numel(data) ~= numel(opt.label)
  error('plotAvalDistrOnAxis:labelsNumber','Number of labels must equal number of data vectors')
end
if numel(data) ~= size(opt.color,1)
  error('plotAvalDistrOnAxis:colorNumber','Number of colors must equal number of data vectors')
end

hold(opt.ax,'on')

for i = numel(data) : -1 : 1
  if opt.polar
    if opt.nbins == 0
      opt.nbins = 25;
    end
    % remap angles in [0,2π)
    angles = mod(data{i},2*pi);
    edges = linspace(0,2*pi,opt.nbins);
    [counts,edges] = histcounts(angles,edges,'Normalization',opt.type);
    % duplicate cycle
    counts = [counts,counts];
    edges = [edges,edges(end)+edges(2:end)];
    % adjust x axes
    set(opt.ax,'XLim',[0,4*pi],'XTick',[0,pi,2*pi,3*pi,4*pi],'XTickLabel',["0","π","2π","3π","4π"])
  elseif opt.nbins ~= 0
    [counts,edges] = histcounts(data{i},opt.nbins,'Normalization',opt.type);
  else
    [counts,edges] = histcounts(data{i},'Normalization',opt.type);
  end
  % center x points in bins
  x = (edges(1:end-1) + edges(2:end)) / 2;
  h(i) = plot(opt.ax,x,counts,'Marker','.','Color',opt.color(i,:),'LineWidth',1.6,'MarkerSize',9,opt.lineprop{:});
  if ~isempty(opt.label)
    h(i).DisplayName = opt.label(i);
  end
end

% adjust axes
if opt.log, scale = 'log'; else, scale = 'linear'; end
set(opt.ax,'XScale',scale,'YScale',scale,'YTick',[]);

% make axis labels
if opt.name ~= ""
  x_label = opt.name;
  y_label = "p("+opt.name+")";
  if opt.log
    x_label = x_label + " (log)";
    y_label = y_label + " (log)";
  end
  if opt.unit ~= ""
    x_label = x_label + " (" + opt.unit + ")";
  end
  xlabel(opt.ax,x_label)
  ylabel(opt.ax,y_label)
end

% make legend
if isempty(opt.label)
  RemoveFromLegend(h)
else
  legend(opt.ax)
end