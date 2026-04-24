function plotDistr(data,opt)
% plotDistr Plot probability density function of data
%
% repeating arguments
%
%
% name-value arguments
%     nbins
%     polar       logical = false, make [0,2*pi] edges
%     log         logical = false, plot on loglog axis
%     label       (:,1) string = [], legend labels
%     color       (:,3), RGB color matrix, one for each element of data
%     lineprop    (:,1) cell = {}, properties passed to plot()
%     name        string = "" % name of the quantity plotted
%     unit        string = ""
%     type        string = "pdf"
%     ax

arguments (Repeating)
  data (:,1) {mustBeNumeric}
end
arguments
  opt.nbins (1,1) {mustBeNumeric,mustBeInteger,mustBeNonnegative} = 0
  opt.polar (1,1) {mustBeLogical} = false
  opt.log (1,1) {mustBeLogical} = false % plot on loglog axis
  opt.label (:,1) string = [] % legend labels
  opt.color (:,3) {mustBeNumeric,mustBeNonnegative,mustBeLessThanOrEqual(opt.color,1)} = myColors(1:numel(data))
  opt.lineprop (:,1) cell = {}
  opt.name (1,1) string = "" % name of the quantity plotted
  opt.unit (1,1) string = ""
  opt.type (1,1) string = "pdf"
  opt.ax (1,1) matlab.graphics.axis.Axes = gca % figure axes
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
    [counts,edges] = histcounts(angles,edges,Normalization=opt.type);
    % duplicate cycle
    counts = [counts,counts];
    edges = [edges,edges(end)+edges(2:end)];
    % adjust x axes
    set(opt.ax,'XLim',[0,4*pi],'XTick',[0,pi,2*pi,3*pi,4*pi],'XTickLabel',["0","π","2π","3π","4π"])
  elseif opt.nbins ~= 0
    [counts,edges] = histcounts(data{i},opt.nbins,Normalization=opt.type);
  else
    [counts,edges] = histcounts(data{i},Normalization=opt.type);
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