function [fig,axs] = makeFigure(name,fig_title,subplots,opt)
% makeFigure Make a figure and return handles
%
% arguments:
%     name          figure name
%     fig_title     string = '', figure title
%     subplots      (2,1) double = [1,1], number of subplots
%
% name-value arguments:
%     show          logical = true, whether to show the figure
%     size          (2,1) double = [NaN,NaN], figure size, default is screen size
%     polar         (:,:) logical = false, specify whether each axis should be polar
%     TileSpacig    string = 'compact', controls subplots spacing (see MATLAB tiledlayout)
%     axProp        cell = {}, additional properties passed to call of axes

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  name (1,1) string
  fig_title (1,1) string = ""
  subplots (2,1) {mustBeNumeric,mustBeInteger,mustBePositive} = [1,1]
  opt.show (1,1) {mustBeLogical} = true
  opt.size (1,2) {mustBeNumeric} = [NaN,NaN]
  opt.polar {mustBeLogical} = false
  opt.TileSpacig (1,1) string = 'compact'
  opt.axProp (:,1) cell = {}
end

if any(opt.size<=0)
  error('makeFigure:sizeValue','Argument ''size'' must be positive')
end
if isscalar(opt.polar)
  opt.polar = repelem(opt.polar,subplots(1)*subplots(2),1);
else
  if numel(opt.polar) ~= subplots(1) * subplots(2)
    error('makeFigure:polar','Argument ''polar'' must have one value per subplot')
  end
  opt.polar = opt.polar.';
end

% make figure of correct size
screen_size = get(0,'Screensize');
pos = screen_size;
pos([false,false,~isnan(opt.size)]) = opt.size(~isnan(opt.size));
% center figure
for i = 1 : 2
  pos(i) = max(pos(i), pos(i)+(screen_size(i+2)-pos(i+2))/2);
end

if opt.show
  fig = figure('Name',name,'NumberTitle','off','Position',pos,'DefaultLineLinewidth',1.3);
else
  fig = figure('Name',name,'NumberTitle','off','Position',pos,'DefaultLineLinewidth',1.3,'Visible','off');
end

t = []; % empty tiledlayout handle, to keep track of whether a suptitle is needed

if any(subplots ~= [1,1])
  t = tiledlayout(subplots(1),subplots(2),TileSpacing=opt.TileSpacig,Padding='compact');
  axs = matlab.graphics.axis.Axes.empty;
  for i = 1 : subplots(1) * subplots(2)
    if opt.polar(i)
      axs(i) = polaraxes(t);
      axs(i).Layout.Tile = i;
      thetaticks([0,90,180,270]), thetaticklabels(["0",'π/2','π','3π/2']), rticks([0.4,0.8])
    else
      axs(i) = nexttile(i);
    end
    hold on
    adjustAxes(axs(i),opt.axProp{:})
  end
else
  if opt.polar
    axs = polaraxes;
    thetaticks([0,90,180,270]), thetaticklabels(["0",'π/2','π','3π/2']), rticks([0.4,0.8])
  else
    axs = gca;
  end
  hold on
  adjustAxes(axs,opt.axProp{:})
end

if fig_title ~= ""
  if isempty(t)
    title(fig_title)
  else
    title(t,fig_title,FontSize=14)
  end
end
