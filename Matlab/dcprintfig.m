function dcprintfig(description,w,v,figuredir,dateFlag)
persistent fignumber;
if isempty(fignumber)
    fignumber = 1;
else
    fignumber = fignumber + 1;
end
if ~exist('figuredir','var') || isempty(figuredir)
    [ST,~] = dbstack;
    figuredir = fullfile('~/figures',ST(2).name);
end

if exist('dateFlag','var')
    [p,n,~] = fileparts(figuredir);
    figuredir = fullfile(p,...
        [datestr(now,'yyyy_mm_dd') '_' n]);
end

if ~exist(figuredir,'dir')
    mkdir(figuredir);
end

if ~exist('w','var');
    w = 9;
end
if ~exist('v','var');
    v = 9;
end

orient tall;
set(gcf, 'PaperPosition', [0 0 w v]);
%print('-depsc',[fullfile(figuredir,description) '_2']);
%print('-depsc2',[fullfile(figuredir,description) '_tmp']);
%system(['/usr/local/bin/eps2eps ' ...
%    fullfile(figuredir,description) '_tmp.eps ' ...
%    fullfile(figuredir,description) '.eps']);
%delete([fullfile(figuredir,description) '_tmp.eps']);
print('-djpeg','-r300',fullfile(figuredir,...
    sprintf('%.3d_%s',fignumber,description)));
%print('-djpeg','-r600',fullfile(figuredir,description));
%print('-dtiff','-r300',fullfile(figuredir,description));
%print('-depsc2','-painters',fullfile(figuredir,description));
%saveas(gcf,fullfile(figuredir,description));

%print('-depsc2',[fullfile(figuredir,description) '_tmp']);


%plot2svg(fullfile(figuredir,description), gcf, 'png'); 
