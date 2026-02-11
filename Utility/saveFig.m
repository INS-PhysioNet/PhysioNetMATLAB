function status = saveFig(fig,file_name,format,opt)
% saveFig Save figure to file
%
% arguments:
%     fig          figure handle, figure to save
%     file_name    string, file name to save figure
%     format       (n_formats,1) string, file types
%
% name-value arguments:
%     res          double = 0, image resolution, default is auto, should not be used for vector graphics
%     pause        double = 0, pause time before saving, useful to allow MATLAB to render figures before saving
%
% output:
%     status       logical, always true; necessary to allow the syntax:
%
%                  >> logical_flag && saveFig(fig,file_name,format);
%
%                  which will save the figure only if logical_flag is true

% NOTE: since R2025a, exportgraphics allows svg format, try implementing in the future

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  fig (1,1) matlab.ui.Figure
  file_name (1,1) string
  format (:,1) string
  opt.res (1,1) {mustBeNumeric,mustBeNonnegative} = 0
  opt.pause (1,1) {mustBeNumeric,mustBeNonnegative} = 0
end

% force graphics update before save  
drawnow

if opt.pause ~= 0
  pause(opt.pause)
end

% forces vector output:
%print(fig,'-vector','-d'+format,file_name+"."+format)
% to try with R2025a:
%exportgraphics(fig,file_name+"."+format,ContentType='vector')

% save in all formats
for fmat = format'
  if fmat == "svg"
    % remove white background from axes
    set(findall(fig,'type','axes'),'Color','none')
  end

  if opt.res == 0
    saveas(fig,file_name+"."+fmat,fmat)
  else
    % specify resolution
    exportgraphics(fig,file_name+"."+fmat,Resolution=opt.res);
  end
end

status = true;