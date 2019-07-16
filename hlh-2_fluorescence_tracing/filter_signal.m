function [signal_filt, filt] = filter_signal(signal, frame_rate,filter_shape,filter_type, varargin)

%
% DESCRIPTION: this function filters a signal with one of two filters,
% Gaussian or Fermi
%
% the array can be a one-dimensional signal or an array of
% one-dimensional signals, 
% array must be of size [length_of_signal x no_signals]
% and filtering is perfomed along the first dimension
%
%
% INPUT ARGUMENTS: 
%
% signal... 
% frame_rate... in Hz!
% filter_shape ... either Fermi or Gaussian
% filter_type ... either 'lowpass' or 'highpass'
%
% varargin for filter_type Gaussian (parameters defined in Real space)
% filter_width  ... sigma of the Gaussian in seconds (i.e. real space!!!)
%
%
% varargin for filter_type Fermi (parameters defined in Fourier space)
% cut_off ... frequency at which the fermi filter kicks in (Fourier Space!!!)
% beta ... stepness of the filter
%
% 
%
% 11/03/2016 Wolfang Keil, The Rockefeller University, 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Noise filtering with Gaussian filter
    % Padd to next FFT-nice size

    signal = signal';
    
    a = size(signal,1);
    ext =round(2.^(ceil(log(a)/log(2)))); %This will be the size of the filters/padded array
    bg=zeros(ext,size(signal,2));     % zero padding

    bg(round((ext-a)/2+1):round((ext-a)/2+a),:)=signal;
    roi_padd = zeros(size(bg));
    roi_padd(round((ext-a)/2+1):round((ext-a)/2+a),:)=1;

    % Define coordinates
    xx = [1:ext]';   % coordinate system
    xx=xx-ext/2;


    switch filter_shape
        case {'gaussian' ,'Gaussian', 'Gauss'}
            xx = xx./frame_rate;
            % Get the filter width from the varargin arguments
            filt_width = varargin{1};          
            
            filt=exp(-(xx.^2)/2/filt_width^2);  
            filt = repmat(filt, [1 size(signal,2)]);
                       
            % Filter signal
            signal_f=fftshift(ifft(fft(fftshift(bg,1), [],1).*fft(fftshift(filt,1), [],1), [],1), 1);           
            % Filter ROI to Take Borders into consideration
            overlap = fftshift(ifft(fft(fftshift(roi_padd,1), [],1).*fft(fftshift(filt,1), [],1)),1);          


            %%%% Decide whether to substract the lowpass or just use the lowpass
            signal_filt = zeros(size(signal_f));

            if strcmpi(filter_type, 'highpass') || strcmpi(filter_type, 'high-pass')
                signal_filt(roi_padd>0) = bg(roi_padd>0) - signal_f(roi_padd>0)./overlap(roi_padd>0);
            elseif strcmpi(filter_type, 'lowpass') || strcmpi(filter_type, 'low-pass')
                signal_filt(roi_padd>0) = signal_f(roi_padd>0)./overlap(roi_padd>0);
            else
                disp('Unknown filter_type: Choose either ''lowpass'' or ''highpass''');
                signal_filt = signal;
                filt = ones(size(signal));
                return;        
            end
            
            
        case {'fermi', 'Fermi'}
            
            % Get the filter width from the varargin arguments
            cut_off = varargin{1};% cut_off 
            bet = varargin{2};    % Filter steepness

            % cut_off is given in Hz, scale cut_off with frame rate
            cut_off=ext*cut_off/frame_rate;
            bet = bet*cut_off;
            
            filt=1./(1+exp((sqrt(xx.^2)-cut_off)./(bet)));
            filt = repmat(filt, [1 size(signal,2)]);
            
            % Filter signal
            signal_f= fftshift(ifft(fft(fftshift(bg,1),[],1).*fftshift(filt,1),[],1), 1);
            % Filter ROI to Take Borders into consideration
            overlap = fftshift(ifft(fft(fftshift(roi_padd,1),[],1).*fftshift(filt,1),[],1),1);   

            % Decide whether to substract the lowpass (=highpass filtering) or just use the lowpass
            signal_filt = zeros(size(signal_f));

            if strcmpi(filter_type, 'highpass') || strcmpi(filter_type, 'high-pass')
                signal_filt(roi_padd>0) = real(bg(roi_padd>0) - signal_f(roi_padd>0)./overlap(roi_padd>0));
                filt = 1-filt;
            elseif strcmpi(filter_type, 'lowpass') || strcmpi(filter_type, 'low-pass')
                signal_filt(roi_padd>0) = real(signal_f(roi_padd>0)./overlap(roi_padd>0));
            else
                disp('Unknown filter_type: Choose either ''lowpass'' or ''highpass''');
                signal_filt = signal;
                filt = ones(size(signal));
                return;        
            end
        otherwise
            disp('Unknown filter shape: Use ''Gaussian'' or ''Fermi''. Returning original signal');
            signal_filt = signal;
            filt = ones(size(signal));
            return;
 
    end
    


    % Chop the padded ends of the signal off again
    signal_filt=signal_filt(round((ext-a)/2+1):round((ext-a)/2+a),:);            
    filt=filt(round((ext-a)/2+1):round((ext-a)/2+a),1);
            
    
            
end    