function plot_fft_2(fft_y, sample_rate, total_samples)
    P2 = abs(fft_y/total_samples);
    P1 = P2(1:floor(total_samples/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    Q = sample_rate*(0:(total_samples/2))/total_samples;
    plot(Q,P1);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
end