% Configuração da comunicação serial
s = serialport("COM3", 115200);  % Ajuste a porta conforme necessário
flush(s);

% Inicialização de variáveis
NUM_SAMPLES = 1024;
VetorX = zeros(1, NUM_SAMPLES);
VetorY = zeros(1, NUM_SAMPLES);
VetorZ = zeros(1, NUM_SAMPLES);
sampleCounter = 0;
errorCounter = 0;

% Loop para ler e processar dados
while sampleCounter < NUM_SAMPLES
    data = readline(s);
    values = split(data, ',');
    
    if strcmp(values(1), 'Sinc')
        % Conversão para valores numéricos
        x = str2double(values(2));
        y = str2double(values(3));
        z = str2double(values(4));
        
        % Verificação se são numéricos
        if isnumeric(x) && isnumeric(y) && isnumeric(z)
            sampleCounter = sampleCounter + 1;
            VetorX(sampleCounter) = (x - offsetX) * scaleFactor;
            VetorY(sampleCounter) = (y - offsetY) * scaleFactor;
            VetorZ(sampleCounter) = (z - offsetZ) * scaleFactor;
        else
            errorCounter = errorCounter + 1;
        end
    end
end

% Aplicar janela de Hann
VetorX = VetorX .* hann(NUM_SAMPLES)';
VetorY = VetorY .* hann(NUM_SAMPLES)';
VetorZ = VetorZ .* hann(NUM_SAMPLES)';

% Cálculo da FFT
fftX = fft(VetorX);
fftY = fft(VetorY);
fftZ = fft(VetorZ);

% Plotagem dos resultados
figure;
subplot(3,1,1);
plot(VetorX);
title('Aceleração Real Eixo X');

subplot(3,1,2);
plot(VetorY);
title('Aceleração Real Eixo Y');

subplot(3,1,3);
plot(VetorZ);
title('Aceleração Real Eixo Z');

% FFTs
figure;
subplot(3,1,1);
plot(abs(fftX));
title('FFT Eixo X');

subplot(3,1,2);
plot(abs(fftY));
title('FFT Eixo Y');

subplot(3,1,3);
plot(abs(fftZ));
title('FFT Eixo Z');

% Salvar dados em .xlsx
dataToSave = [VetorX' VetorY' VetorZ'];
writematrix(dataToSave, 'aceleracao_dados.xlsx');
