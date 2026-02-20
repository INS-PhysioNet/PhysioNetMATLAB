function [sessions,args] = readBatchFile(file)

% get lines
fileID = fopen(file);
if fileID == -1
  error('readBatchFile:fOpen',"Unable to open "+file);
end
lines = textscan(fileID,'%s',CommentStyle='%',Delimiter='\n');
fclose(fileID);

% parse lines
sessions = strings().empty();
args = {};
for line = lines{1}.'
  if ~isempty(line{1})
    split = strsplit(line{1},'%'); % remove everything after first '%'
    words = textscan(split{1},'%s',CommentStyle='%');
    sessions(end+1,1) = words{1}{1};

    % assign following words as session-specific args
    args{numel(sessions),1} = {};
    for i = 2 : numel(words{1})
      args{numel(sessions)}{i-1,1} = eval(words{1}{i});
    end
  end
end

