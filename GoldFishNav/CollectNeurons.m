function [ neuron ] = CollectNeurons
%COLLECTNEURONS Summary of this function goes here
%   Detailed explanation goes here
main=pwd;

path='C:\Users\pinskyeh\Dropbox\ExpData\NLoger\';
[~,~,raw]=xlsread([path 'ExperimentList2.xlsx'],'NeuronsList');
CurrentExp=[];
CurrentDay=[];

for i=2:size(raw,1)
    if ~strcmp(CurrentExp,raw{i,1})|CurrentDay~=raw{i,2}
        CurrentExp=raw{i,1};
        CurrentDay=raw{i,2};
        cd ([path , CurrentExp, '\Day', num2str(CurrentDay) '\']);
        temp=load ('CombinedData.mat');
    end
    Cluster=raw{i,3};
%         neuron(i-1)=DlvNeuron(temp.Time,temp.X,temp.Y,temp.Orient,temp.T(temp.I==Cluster),temp.Rect,temp.S,CurrentExp,CurrentDay,Cluster);
    neuron(i-1)=DlvNeuron(temp.Time,temp.X,temp.Y,temp.Orient,temp.T(temp.I==Cluster),temp.Rect,[],CurrentExp,CurrentDay,Cluster);
end
cd (main);