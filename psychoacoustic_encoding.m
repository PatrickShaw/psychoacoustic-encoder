function [n_y, total_components, total_windows, total_components_removed] = psychoacoustic_encoding(o_y, o_fs, window_overlap_count, window_time_width, octave_analysis_range, softer_factor_threshold, octave_distance_weighting, read_path, write_path, show_plot)
    total_components_removed = 0;
    total_windows = 0;

    n_y = zeros(size(o_y));
    % Number of elements per window.
    window_sample_width = round(o_fs * (window_time_width / 1000)); 
    audio_sample_len = size(o_y, 1);
    channel_len = size(o_y, 2);
    total_components = 0;
    % This loop analyses audio in intervals of <window_sample_width> samples
    % and removes all frequencies that are considered to be masked by other
    % frequencies.
    w = 1;
    while w <= audio_sample_len
        end_window_index = min(w + (window_sample_width - 1), audio_sample_len);
        for c = 1:channel_len
            % Grab the fast fourier transform so that we can determine what 
            % frequencies are being overpowered by other frequencies in the
            % sample.
            fft_y = fft(o_y(w:end_window_index, c));
            fft_y_len = size(fft_y, 1);
            % Abs the FFT so we can look at soley the amplitude of the frequencies.
            % The FFT, otherwise, would be covered in complex numbers.
            fft_y_abs = abs(fft_y);
            % Ignore the 0Hz
            f = 2; 
            while f <= fft_y_len
                amplitude = fft_y_abs(f);
                frequency = fft_index_to_hz(f, o_fs, fft_y_len);
                if amplitude ~= 0 && frequency ~= 0
                    other_f = max(2, floor(octave_to_fft_index(-octave_analysis_range, frequency, o_fs, fft_y_len)));
                    other_frequency = fft_index_to_hz(f, o_fs, fft_y_len);
                    other_f_end_index = min(fft_y_len, ceil(octave_to_fft_index(octave_analysis_range, frequency, o_fs, fft_y_len)));
                    % The maximum amount of 'softness' out of all the frequencies 
                    % that we compared the frequency we're look at with.
                    max_softer_factor = 0;
                    while other_f <= other_f_end_index
                        if other_frequency ~= 0 && f ~= other_f
                            % How disimilar two wavelengths are to each other in.
                            octave_difference = abs(octaves(frequency, other_frequency));
                            other_amplitude = fft_y_abs(other_f);
                            % How soft the analysed frequency is to the other
                            % frequency.
                            softness = other_amplitude/amplitude;
                            % The weighted softness (we prefer not to remove
                            % the component if the other frequency is too
                            % distant).
                            relative_softness = softness * (1/(octave_distance_weighting * octave_difference + 1));
                            max_softer_factor = max(relative_softness, max_softer_factor);
                        end
                        other_f = other_f + 1;
                    end
                    if max_softer_factor >= softer_factor_threshold
                        fft_y(f) = 0;
                        total_components_removed = total_components_removed + 1;
                    end
                end
                f = f + 1;
            end
            % disp(total_windows);
            ifft_y = ifft(fft_y, 'symmetric');
            n_y(w:end_window_index, c) = ifft_y;
            % Add 1 window per channel
            total_windows = total_windows + 1;
            total_components = total_components + fft_y_len;
        end
        if total_windows == 100 && show_plot == 0
            figure;
            hold on;
            plot_fft(o_y(w:end_window_index, c), o_fs, fft_y_len);
            plot_fft_2(fft_y, o_fs, fft_y_len);
            hold off;
            legend(sprintf('Original %s', read_path), sprintf('Encoded %s', write_path));
            title(sprintf('Sample window (%d-%d, channel %d) - Amplitude spectrum', w, end_window_index, c));
        end
        % Ideally we would slide over the samples but that would take too long,
        % instead, increase the window starting position by half of the window
        % width.
        w = w + ceil(window_sample_width / window_overlap_count);
    end
end
function hz = fft_index_to_hz(index, fs, fft_len)
    hz = index * hz_per_fft_index(fs, fft_len);
end
function index = octave_to_fft_index(octaves, original_hz, fs, fft_len)
    index = octave_frequency(octaves, original_hz) / hz_per_fft_index(fs, fft_len);
end
function hz = hz_per_fft_index(fs, fft_len)
    hz = fs/(fft_len + 1);
end
function f = octave_frequency(octaves, hz)
    f = (2^octaves) * hz;
end
function o = octaves(frequency_1, frequency_2)
    o = log2(frequency_1 / frequency_2);
end
