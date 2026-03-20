function pBar(p,x,alpha,opt)
% pBar Draw horizontal bars representing significant differences between distributions (e.g., between boxplots)
%
% arguments
%     p        (:,3) double, each row is [id1, id2 ,p-value], resulting from the comparison of distributions id1 and id2
%     x        (:,1) double, x coordinates of distributions (e.g., of boxplots), one element for every id in 'p'
%     alpha    double = 0.05, tolerance level for false positive detection
%
% name-value arguments:
%     dy       double = 1, scaling factor for vertical distance between horizontal bars
%     draw     (4,1) logical = [true,true,true,false], whether to draw bars corresponding to [n.s., *, **, ***]
%     ax       Axes = gca, axes to plot in

arguments
  p (:,3)
  x (:,1) = (1 : size(p,1)).'
  alpha (1,1) {mustBeNumeric} = 0.05
  opt.dy (1,1) {mustBeNumeric} = 1
  opt.draw (4,1) {mustBeLogical} = [true,true,true,false]
  opt.ax (1,1) matlab.graphics.axis.Axes = gca
end

dx = diff(xlim(opt.ax)) / 500;
yLim = ylim(opt.ax);
height = yLim(2);
dy = diff(yLim) / 80 * opt.dy;

% sort according to distance: nearby pairs first, then second neighbours and so on
distances = round(diff(x(p(:,1:2)),1,2),10);
[~,ind] = sortrows([distances,x(p(:,1))]); % sortrows breaks ties by smaller x
p = p(ind,:);

% h
h = p(:,3);
if alpha ~= -1
  h(p(:,3) < alpha) = 1;
  h(p(:,3) < alpha/5) = 2;
  h(p(:,3) < alpha/50) = 3;
  h(p(:,3) >= alpha) = 0;
end

% plot
last_i = 0;
for i = 1 : size(p,1)

  x_coord = [x(p(i,1))+dx ,x(p(i,2))-dx];
  
  if h(i) == 3 && opt.draw(1)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i,"***",opt.ax);
  elseif h(i) >= 2 && opt.draw(2)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i,"**",opt.ax);
  elseif h(i) >= 1 && opt.draw(3)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i,"*",opt.ax);
  elseif h(i) == 0 && opt.draw(4)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i,"n.s.",opt.ax);
  end

end

ylim(opt.ax,[yLim(1),height+dy*5])

end

function [y,last_p] = plotLine(x,y,dy,p,last_p,t,ax)

  % increase height not to overlap lines
  if last_p > p(1)
    y = y + dy*3;
  end
  h1 = plot(ax,repelem(x,1,2),y+[-dy,0,0,-dy],'k','HandleVisibility','off');
  if t == "n.s."
    height = y;
    valignment = "bottom";
  else
    height = y - 0.5*dy;
    valignment = "baseline";
  end
  h2 = text(ax,mean(x),height,t,'FontSize',gca().FontSize,'HorizontalAlignment','center','VerticalAlignment',valignment,'HandleVisibility','off');
  last_p = p(2);

end