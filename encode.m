path = 'snippet.flac';
% In milliseconds
window_time_width = 4; 
%t = 0:1/50:10-1/50;                     
%o_y = sin(2*pi*15*t) + sin(2*pi*20*t);
[o_y, o_fs] = audioread(path);
audio_info = audioinfo(path);
disp(audio_info);
% Number of elements per window
window_sample_width = round(audio_info.SampleRate * (window_time_width / 1000)); 
audio_sample_len = size(o_y, 1);
disp("Window sample width: " + window_sample_width);
w = 1;
channel_len = size(o_y, 2);
while w <= audio_sample_len
    % Grab the fast fourier transform so that we can determine what 
    % frequencies are being overpowered by other frequencies in the sample
    end_window_index = min(w + (window_sample_width - 1), audio_sample_len);
    for c = 1:channel_len
        fft_y = fft(o_y(w:end_window_index, c));
        fft_y_1_len = size(fft_y, 1);
        % Abs the FFT so we can look at soley the amplitude of the frequencies.
        % The FFT, otherwise, would be covered in complex numbers.
        fft_y_abs = abs(fft_y);
        fft_y(fft_y_abs < 0.1) = 0;
        n_y = ifft(fft_y);
        for i = 1:fft_y_1_len            
            o_y(w + (i - 1), c) = n_y(i);
        end
    end
    w = end_window_index + 1;
end
plot(abs(fftshift(fft(o_y))));
sound(o_y, o_fs);
audiowrite('snippet-output.flac', o_y, o_fs, 'BitsPerSample', audio_info.BitsPerSample);