% Where we are reading our audio from.
read_path = './results/snippet.flac';
% Where we are writing our encoded audio to.
write_path = './results/snippet-output-1.flac';
% Number of overlapping that happens between each window.
window_overlap_count = 2;
% Range of octaves to analyse for a given frequency.
octave_analysis_range = 1;
% How soft something has to be, relative to the loudest nearby frequency,
% to be removed from the audio.
softer_factor_threshold = 10;
% The further apart an amplitude spike is from other frequencies, the less 
% likely it is to drown out said frequency. This variable specifies how 
% much 'softer' said frequency's amplitude has to be to be considered 
% masked by the other frequency by this equation:
% Drowned out = softness * (1/(octave_distance_weighting * octave_difference + 1)) >
% softer_factor_threshold.
octave_distance_weighting = 4;
% How much of the audio we are analysing, in milliseconds, at any given
% amount of time.
window_time_width = 4;

% Read the audio.
[o_y, o_fs] = audioread(read_path);
audio_sample_len = size(o_y, 1);

audio_info = audioinfo(read_path);
disp(audio_info);

[n_y, total_components, total_windows, total_components_removed] = ...
    encode(...
        o_y, n_y, o_fs, window_overlap_count, window_time_width, ...
        octave_analysis_range, softer_factor_threshold, ...
        octave_distance_weighting, read_path, write_path...
    );

figure;
plot_fft(o_y, o_fs, audio_sample_len);
title(sprintf('Original %s - Amplitude spectrum', read_path));

figure;
plot_fft(n_y, o_fs, audio_sample_len);
title(sprintf('Encoded %s - Amplitude spectrum', write_path));

sound(n_y, o_fs);
audiowrite(write_path, n_y, o_fs, 'BitsPerSample', audio_info.BitsPerSample);

average_components_removed_per_window = total_components_removed / total_windows;
fprintf('Average components removed per window: %f\n', average_components_removed_per_window);

ratio_average_components_removed_vs_total_components = total_components_removed / total_components;
fprintf('Percent average components removed per window: %f%%\n', ratio_average_components_removed_vs_total_components * 100);

fprintf('Sum squared error: %f\n', sum(sum_squared_error(o_y, n_y)));
