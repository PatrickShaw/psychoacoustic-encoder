% Where we are reading our audio from.
read_path = './results/snippet_smaller.flac';
% Where we are writing our encoded audio to.
write_path = 'N/A';
% Number of overlapping that happens between each window.
window_overlap_count = 2;
% How soft something has to be, relative to the loudest nearby frequency,
% to be removed from the audio.
softer_factor_threshold = 0;
% Range of octaves to analyse for a given frequency.
octave_analysis_range = 1;
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

max_softer_factor_threshold = 20;
softer_increment_rate = 0.5;
x_axis_count = ceil(max_softer_factor_threshold / softer_increment_rate);
x_axis = zeros(x_axis_count, 1);
y_axis_total_components_removed = zeros(x_axis_count, 1);
y_axis_sum_squared_error = zeros(x_axis_count, 1);
i = 1;
while softer_factor_threshold <= max_softer_factor_threshold
    [n_y, total_components, total_windows, total_components_removed] = ...
        psychoacoustic_encoding(...
            o_y, o_fs, window_overlap_count, window_time_width, ...
            octave_analysis_range, softer_factor_threshold, ...
            octave_distance_weighting, read_path, write_path, 1 ...
        );
    x_axis(i) = softer_factor_threshold;
    y_axis_total_components_removed(i) = total_components_removed;
    y_axis_sum_squared_error(i) = sum(sum_squared_error(o_y, n_y));
    i = i + 1;
    softer_factor_threshold = softer_factor_threshold + softer_increment_rate;
end
disp(y_axis_sum_squared_error);
figure;
title('Total components removed vs Softer factor threshold');
plot(x_axis, y_axis_total_components_removed);
xlabel('Softer factor threshold');
ylabel('Total components removed');

figure;
title('Sum squared error vs Softer factor threshold');
plot(x_axis, y_axis_sum_squared_error);
xlabel('Softer factor threshold');
ylabel('Sum squared error');

figure;
title('Sum squared error vs Total components removed');
plot(x_axis, y_axis_sum_squared_error);
xlabel('Total components removed');
ylabel('Sum squared error');
