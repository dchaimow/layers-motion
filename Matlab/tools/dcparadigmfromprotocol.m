function paradigm = dcparadigmfromprotocol(protocol,baselineCondition)
%DCPARADIGMFROMPROTOCOL  ...
%   Requirements
%
%   Design
%
%   Interfaces
%
%   Discussion
%

% Copyright 2009 Denis Chaimow.
% Created by Denis Chaimow on 07-May-2009 19:25:00
% $Id$'

%TODO: Write documentation
%TODO: Implement first version
tmpdir = '~/tmp';
tokens = regexp(protocol.program,'condition(\S*)\s*=\s*(\S*);','tokens');
zCondition = 0;


for z=1:length(tokens)
      if ~isempty(tokens{z})
          conditionName = tokens{z}{1}{1};
          conditionNumber = str2num(tokens{z}{1}{2});
          if ~strcmpi(conditionName, baselineCondition) & ...
                  logical(conditionNumber)
             zCondition = zCondition + 1;
             conditionList{zCondition} = conditionName;
             conditionNumbers(zCondition) = conditionNumber;
          end
      end
end

nPredictors = length(conditionList);


if ~isfield(protocol,'paradigm')
   firstLine = find(strcmp(protocol.program,'%% List of conditions'));
   lastLine = find(strcmp(protocol.program,'%% Open screen')) - 1;
   
   fName = fullfile(tmpdir,...
       ['script' datestr(now,30) num2str(cputime*100) num2str(round(rand*100000)) '.m']);
   fid = fopen(fName,'w');
   for z=firstLine:lastLine
    fprintf(fid, [protocol.program{z} '\n']);
   end
   fclose(fid);
   paradigmNumber = protocol.paradigmNumber;
   run(fName);
   protocol.paradigm = paradigm;
   clear paradigm;
   delete(fName);
end


for zCondition=1:nPredictors
    conditionStartTimes{zCondition} = protocol.paradigm(...
        find(protocol.paradigm(:,2)==conditionNumbers(zCondition)),1);
    conditionStopTimes{zCondition} = protocol.paradigm(...
        find(protocol.paradigm(:,2)==conditionNumbers(zCondition))+1,1);
end

paradigm.conditionList = conditionList;
paradigm.startTimes = conditionStartTimes;
paradigm.stopTimes = conditionStopTimes;
paradigm.paradigm = protocol.paradigm;