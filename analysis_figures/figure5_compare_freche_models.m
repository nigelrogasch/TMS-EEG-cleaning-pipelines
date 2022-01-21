% ##### PLOT FIGURE 5 #####

% This script plots the raw TEPs and the Freche model fits from the
% original pipeline and following optimisation of the Freche model used in
% figure 5 of the manuscript.

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
ID = {'121'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';
pathOut = '/projects/kg98/Nigel/TMS-EEG_cleaning_pipeline/figures/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Load the data
idx = 1;

filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_','step2','.set'];        
EEG1 = pop_loadset('filename',filename,'filepath',pathIn);
filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_','step3','_','FrecheModel','.set'];        
EEG2 = pop_loadset('filename',filename,'filepath',pathIn);
filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_','step3','_','FrecheModelAlt','.set'];        
EEG3 = pop_loadset('filename',filename,'filepath',pathIn);

% Remove bad channels
EEG1 = pop_select( EEG1,'nochannel',EEG1.badchannels);

fig = figure('color','w');
set(gcf,'position',[250,60,850,400]);

subplot(1,2,1)
plot(EEG1.times(EEG2.modelTime),mean(EEG1.data(15,EEG2.modelTime,:),3),'k','linewidth',2); hold on;
plot(EEG1.times(EEG2.modelTime),mean(EEG2.modelOutput(15,:,:),3),'r','linewidth',2);
plot(EEG1.times(EEG2.modelTime),mean(EEG1.data(3,EEG2.modelTime,:),3),'k','linewidth',2); hold on;
plot(EEG1.times(EEG2.modelTime),mean(EEG2.modelOutput(3,:,:),3),'r','linewidth',2);

set(gca,'box','off','xlim',[0,500],'ylim',[-40,20],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

text(-125,22,'A','fontsize',16,'fontweight','bold');

subplot(1,2,2)
h1 = plot(EEG1.times(EEG3.modelTime),mean(EEG1.data(15,EEG3.modelTime,:),3),'k','linewidth',2); hold on;
h2 = plot(EEG1.times(EEG3.modelTime),mean(EEG3.modelOutput(15,:,:),3),'r','linewidth',2);
plot(EEG1.times(EEG3.modelTime),mean(EEG1.data(3,EEG3.modelTime,:),3),'k','linewidth',2); hold on;
plot(EEG1.times(EEG3.modelTime),mean(EEG3.modelOutput(3,:,:),3),'r','linewidth',2);

set(gca,'box','off','xlim',[0,500],'ylim',[-40,20],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

lgd = legend([h1,h2],{'Data','Model'},'box','off','location','southeast','fontsize',12);

text(-125,22,'B','fontsize',16,'fontweight','bold');

saveas(fig,[pathOut,'compare_model_settings.png']);
saveas(fig,[pathOut,'figure5.png']);


