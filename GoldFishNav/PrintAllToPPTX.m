PPName='AllNeuronsV1.pptx';
FigsDir='C:\projects\GoldfishAnalysis\tmp\';
figs = dir(strcat(FigsDir, '*.fig'));
numOfNeurons = length(figs);
%% Start new presentation
isOpen  = exportToPPTX();
if ~isempty(isOpen)
    % If PowerPoint already started, then close first and then open a new one
    exportToPPTX('close');
end

exportToPPTX('new','Dimensions',[10 5.625]);
%%

for i=1:numOfNeurons
  fig = openfig(strcat(FigsDir,figs(i).name));
  set (gcf,'units','inch','position',[1,1,10,5.625]);
  exportToPPTX('addslide');
  exportToPPTX('addpicture',gcf);
  close all
end

exportToPPTX('save','tmp2');
