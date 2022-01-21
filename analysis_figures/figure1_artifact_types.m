% ##### PLOT FIGURE 1 #####

% This script generates figure 1 from the manuscript.

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';
pathOut = '/projects/kg98/Nigel/TMS-EEG_cleaning_pipeline/figures/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Fieldtrip
addpath('/projects/kg98/Mana/Scripts/Toolboxes/fieldtrip-20180619');
ft_defaults;

% Load the data

% Pulse - 129 127 126
filename = ['129','_FEF_Decaytest_withTMSPulse_tr_ch.set'];
EEG1 = pop_loadset('filename',filename,'filepath',pathIn);

% Decay - 143
filename = ['143','_FEF_Decaytest_withTMSPulse_tr_ch.set'];
EEG2 = pop_loadset('filename',filename,'filepath',pathIn);

% Muscle - 133 149 132 125
filename = ['132','_FEF_Decaytest_withTMSPulse_tr_ch.set'];
EEG3 = pop_loadset('filename',filename,'filepath',pathIn);

% Interpolate missing electrodes
EEG1 = pop_interp(EEG1, EEG1.allchan, 'spherical');
EEG2 = pop_interp(EEG2, EEG2.allchan, 'spherical');
EEG3 = pop_interp(EEG3, EEG3.allchan, 'spherical');

% Rereference to average
EEG1 = pop_reref( EEG1, []);
EEG2 = pop_reref( EEG2, []);
EEG3 = pop_reref( EEG3, []);

%%
close all;

% Plot the data
fig = figure('color','w');
set(gcf,'position',[125,250,1600,500]);

c = get(0, 'DefaultAxesColorOrder');

[~,t1] = min(abs(EEG1.times-0));
[~,t2] = min(abs(EEG1.times-2));


subplot(1,3,1)
plot(EEG1.times,mean(EEG1.data,3),'k');hold on;
plot(EEG1.times(t1:t2),mean(EEG1.data(:,t1:t2,:),3),'color',c(1,:));

[~,t3] = min(abs(EEG1.times-2.1));
[~,t4] = min(abs(EEG1.times-6));
plot(EEG1.times(t3:t4),mean(EEG1.data(:,t3:t4,:),3),'color',c(2,:));

% plot([5,5],[-1000,1000],'r--');
% plot([10,10],[-1000,1000],'b--');
set(gca,'xlim',[-5,30],'ylim',[-3500,3500],'box','off','tickdir','out','linewidth',2,'fontsize',16);
%title(ID{idx});
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

text(-17,3500,'A','fontsize',20,'fontweight','bold');

subplot(1,3,2)
plot(EEG2.times,mean(EEG2.data,3),'k');hold on;

[~,t1] = min(abs(EEG1.times-0));
[~,t2] = min(abs(EEG1.times-2.5));
plot(EEG2.times(t1:t2),mean(EEG2.data(:,t1:t2,:),3),'color',c(1,:));

[~,t3] = min(abs(EEG1.times-1.5));
[~,t4] = min(abs(EEG1.times-30));
plot(EEG2.times(t3:t4),mean(EEG2.data(21,t3:t4,:),3),'color',c(2,:),'linewidth',2);
% plot([5,5],[-1000,1000],'r--');
% plot([10,10],[-1000,1000],'b--');
set(gca,'xlim',[-5,30],'ylim',[-3500,3500],'box','off','tickdir','out','linewidth',2,'fontsize',16);%title(ID{idx});
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

text(-17,3500,'B','fontsize',20,'fontweight','bold');

subplot(1,3,3)
plot(EEG3.times,mean(EEG3.data,3),'k');hold on;

[~,t1] = min(abs(EEG1.times-0));
[~,t2] = min(abs(EEG1.times-2.1));
plot(EEG3.times(t1:t2),mean(EEG3.data(:,t1:t2,:),3),'color',c(1,:));

[~,t3] = min(abs(EEG1.times-2.1));
[~,t4] = min(abs(EEG1.times-12));
plot(EEG3.times(t3:t4),mean(EEG3.data(:,t3:t4,:),3),'color',c(2,:));

% plot([5,5],[-1000,1000],'r--');
% plot([10,10],[-1000,1000],'b--');
set(gca,'xlim',[-5,30],'ylim',[-3500,3500],'box','off','tickdir','out','linewidth',2,'fontsize',16);%title(ID{idx});
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

text(-17,3500,'C','fontsize',20,'fontweight','bold');

saveas(fig,[pathOut,'compare_artifact_types','.png']);
saveas(fig,[pathOut,'figure1','.png']);