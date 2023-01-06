% Read the input audio
[message_1, fs_1] = audioread('Input/audio_1.m4a');
[message_2, fs_2] = audioread('Input/audio_2.m4a');
[message_3, fs_3] = audioread('Input/audio_3.m4a');

% Select first channel for the three signals
message_1 = message_1(:, 1);
message_2 = message_2(:, 1);
message_3 = message_3(:, 1);

% Set Sampling Frequency (They are all the same)
fs = fs_1;

% Get length of the 3 signals
N_1 = length(message_1);
N_2 = length(message_2);
N_3 = length(message_3);

% Get the maximum length among them
max_N = max([N_1, N_2, N_3]);

% Adjust all lengths of the 3 input signals to be the same
message_1 = [message_1;zeros(max_N-N_1, 1)];
message_2 = [message_2;zeros(max_N-N_2, 1)];
message_3 = [message_3;zeros(max_N-N_3, 1)];

% Time & Frequency interval
time = linspace(0, max_N/fs, max_N);
df = fs/2;
freq = -df : fs/max_N: df - fs/max_N;

% Amplitude and phase in frequency domain
message_f1 = fftshift(fft(message_1));
message_f2 = fftshift(fft(message_2));
message_f3 = fftshift(fft(message_3));

phase_1 = unwrap(angle(message_f1));
phase_2 = unwrap(angle(message_f2));
phase_3 = unwrap(angle(message_f3));

% Carrier Frequency
fc_1 = 4750;
fc_2 = 3 * fc_1;

wc_1 = 2*pi * fc_1;
wc_2 = 2*pi * fc_2;

% Carrier Equation in time domain
carrier_t1 = cos(wc_1 * time); 
carrier_t2 = cos(wc_2 * time);
carrier_t3 = sin(wc_2 * time); 

% Carrier amplitude and phase in frequency domain
carrier_f1 = fftshift(fft(carrier_t1));
carrier_f2 = fftshift(fft(carrier_t2));
carrier_f3 = fftshift(fft(carrier_t3));

phase_carrier1 = unwrap(angle(carrier_f1));
phase_carrier2 = unwrap(angle(carrier_f2));
phase_carrier3 = unwrap(angle(carrier_f3));

% Apply DSB-SC Modulation
modulatedSignal_t1 = message_1' .* carrier_t1;
modulatedSignal_t2 = message_2' .* carrier_t2;
modulatedSignal_t3 = message_3' .* carrier_t3;

% Modulated Signals in frequency domain
modulatedSignal_f1 = fftshift(fft(modulatedSignal_t1));
modulatedSignal_f2 = fftshift(fft(modulatedSignal_t2));
modulatedSignal_f3 = fftshift(fft(modulatedSignal_t3));

phase_mod1 = unwrap(angle(modulatedSignal_f1));
phase_mod2 = unwrap(angle(modulatedSignal_f2));
phase_mod3 = unwrap(angle(modulatedSignal_f3));

% Add modulated signals
finalModulatedSignal = modulatedSignal_t1 + modulatedSignal_t2 + modulatedSignal_t3;

% Get modulated signal amplitude and phase in frequency domain
finalModulatedSignal_f = fftshift(fft(finalModulatedSignal));
phase_mod = unwrap(angle(finalModulatedSignal_f));

% Set passband frequency
fp = fc_1;

% Synchronous Demodulation
demodulate(finalModulatedSignal, carrier_t1, fs, fp, "result1_Sync");
demodulate(finalModulatedSignal, carrier_t2, fs, fp, "result2_Sync");
demodulate(finalModulatedSignal, carrier_t3, fs, fp, "result3_Sync");

% Phase Shift = 10
[carrier1_10, carrier2_10, carrier3_10] = generateCarriersWithPhase(fc_1, fc_2, time, 10);
demodulate(finalModulatedSignal, carrier1_10, fs, fp, "result1_10");
demodulate(finalModulatedSignal, carrier2_10, fs, fp, "result2_10");
demodulate(finalModulatedSignal, carrier3_10, fs, fp, "result3_10");

% Phase Shift = 30
[carrier1_30, carrier2_30, carrier3_30] = generateCarriersWithPhase(fc_1, fc_2, time, 30);
demodulate(finalModulatedSignal, carrier1_30, fs, fp, "result1_30");
demodulate(finalModulatedSignal, carrier2_30, fs, fp, "result2_30");
demodulate(finalModulatedSignal, carrier3_30, fs, fp, "result3_30");

% Phase Shift = 90
[carrier1_90, carrier2_90, carrier3_90] = generateCarriersWithPhase(fc_1, fc_2, time, 90);
demodulate(finalModulatedSignal, carrier1_90, fs, fp, "result1_90");
demodulate(finalModulatedSignal, carrier2_90, fs, fp, "result2_90");
demodulate(finalModulatedSignal, carrier3_90, fs, fp, "result3_90");

% Demodulation with local carrier frequency different than Fc by 2 Hz
[carrier1_2Hz, carrier2_2Hz, carrier3_2Hz] = generateCarriersWithDifferentFc(fc_1, fc_2, time, 2);
demodulate(finalModulatedSignal, carrier1_2Hz, fs, fp, "result1_2Hz");
demodulate(finalModulatedSignal, carrier2_2Hz, fs, fp, "result2_2Hz");
demodulate(finalModulatedSignal, carrier3_2Hz, fs, fp, "result3_2Hz");

% Demodulation with local carrier frequency different than Fc by 10 Hz
[carrier1_10Hz, carrier2_10Hz, carrier3_10Hz] = generateCarriersWithDifferentFc(fc_1, fc_2, time, 10);
demodulate(finalModulatedSignal, carrier1_10Hz, fs, fp, "result1_10Hz");
demodulate(finalModulatedSignal, carrier2_10Hz, fs, fp, "result2_10Hz");
demodulate(finalModulatedSignal, carrier3_10Hz, fs, fp, "result3_10Hz");

% Plot Message Signals
draw(time, freq.', 1, message_1, abs(message_f1), phase_1, 'Message 1');
draw(time, freq.', 2, message_2, abs(message_f2), phase_2, 'Message 2');
draw(time, freq.', 3, message_3, abs(message_f3), phase_3, 'Message 3');

% Plot Modulated Signals
draw(time, freq.', 4, modulatedSignal_t1, abs(modulatedSignal_f1), phase_mod1, 'Modulated 1');
draw(time, freq.', 5, modulatedSignal_t2, abs(modulatedSignal_f2), phase_mod2, 'Modulated 2');
draw(time, freq.', 6, modulatedSignal_t3, abs(modulatedSignal_f3), phase_mod3, 'Modulated 3');

% Plot the Final Modulated Signal
draw(time, freq.', 7, finalModulatedSignal, abs(finalModulatedSignal_f), phase_mod, 'FINAL Modulated Signal');

function draw(time, freq, i, mt, mf, phase, T)
    figure(i)
    subplot(3, 1, 1)
    plot(time, mt)
    xlabel('Time')
    ylabel('Amp')
    title(strcat(T, ' Signal (Time)'))
    
    subplot(3, 1, 2)
    plot(freq, mf)
    xlabel('Freq')
    ylabel('Amp')
    title(strcat(T, ' Signal Amplitude (Freq)'))
    
    subplot(3, 1, 3)
    plot(freq, phase)
    xlabel('Freq')
    ylabel('Phase')
    title(strcat(T, ' Signal Phase (Freq)'))
end

function demodulate(signal, carrier, fs, fp, filename)
    demodulatedSignal = 2 * (signal .* carrier);
    lpf = lowpass(demodulatedSignal, fp, fs);
    
    lpf_f = fftshift(fft(lpf));
    phase_demod = unwrap(angle(lpf_f));
    
    audiowrite(strcat("Output/", filename, '.m4a'), lpf, fs);
end

function [carrier1, carrier2, carrier3] = generateCarriersWithPhase(fc_1, fc_2, time, deg)
     phaseShift = (deg * pi) / 180; 
     
     wc_1 = 2*pi * fc_1;
     wc_2 = 2*pi * fc_2;
     
     carrier1 = cos((wc_1 * time) + phaseShift);
     carrier2 = cos((wc_2 * time) + phaseShift);
     carrier3 = sin((wc_2 * time) + phaseShift);
end

function [carrier1, carrier2, carrier3] = generateCarriersWithDifferentFc(fc_1, fc_2, time, dfc)
     wc_1 = 2*pi * (fc_1 + dfc);
     wc_2 = 2*pi * (fc_2 + dfc);
     
     carrier1 = cos(wc_1 * time);
     carrier2 = cos(wc_2 * time);
     carrier3 = sin(wc_2 * time);
end