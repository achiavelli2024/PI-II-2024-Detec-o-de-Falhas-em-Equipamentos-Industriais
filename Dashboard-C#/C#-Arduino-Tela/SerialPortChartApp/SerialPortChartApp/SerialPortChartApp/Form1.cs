using System;
using System.IO.Ports;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting; // Alias não necessário aqui
using MathNet.Numerics;
using MathNet.Numerics.IntegralTransforms;
using System.Numerics; // Para a classe Complex
using System.Linq;

using ChartSeries = System.Windows.Forms.DataVisualization.Charting.Series;
using NumericsSeries = MathNet.Numerics.Series;


// Adicione um alias para o namespace da biblioteca de gráficos
using ChartingSeries = System.Windows.Forms.DataVisualization.Charting.Series;
using System.Drawing;

namespace SerialPortChartApp
{
    public partial class Form1 : Form
    {
        private SerialPort serialPort;
        private string dataBuffer = ""; // Buffer para armazenar dados recebidos parcialmente

        private double[] xSamples = new double[512]; // Exemplo de 256 amostras para X
        private double[] ySamples = new double[512]; // Exemplo de 256 amostras para Y
        private double[] zSamples = new double[512]; // Exemplo de 256 amostras para Z
        private int sampleIndex = 0;

        public Form1()
        {
            InitializeComponent();
            InitializeChart();
            ListAvailablePorts();  // Chame a função para listar portas
        }

        private void ListAvailablePorts()
        {
            comboBoxPorts.Items.Clear();  // Limpa o ComboBox
            string[] ports = SerialPort.GetPortNames();  // Obtém as portas disponíveis
            comboBoxPorts.Items.AddRange(ports);

            if (ports.Length > 0)
            {
                comboBoxPorts.SelectedIndex = 0;  // Seleciona a primeira porta por padrão
            }
            else
            {
                MessageBox.Show("Nenhuma porta serial encontrada!");
            }
        }

        private void InitializeChart()
        {
            // Limpa qualquer configuração anterior
            chart1.Series.Clear();
            chart1.ChartAreas.Clear();
            chart1.Legends.Clear(); // Limpa qualquer legenda anterior

            // Cria e adiciona uma nova área de gráfico
            ChartArea chartArea = new ChartArea();
            chart1.ChartAreas.Add(chartArea);

            // Cria e adiciona as séries para X, Y e Z
            System.Windows.Forms.DataVisualization.Charting.Series seriesX = new System.Windows.Forms.DataVisualization.Charting.Series("X")
            {
                ChartType = SeriesChartType.Line,
                XValueType = ChartValueType.DateTime,
                Color = System.Drawing.Color.Red
            };
            chart1.Series.Add(seriesX);

            System.Windows.Forms.DataVisualization.Charting.Series seriesY = new System.Windows.Forms.DataVisualization.Charting.Series("Y")
            {
                ChartType = SeriesChartType.Line,
                XValueType = ChartValueType.DateTime,
                Color = System.Drawing.Color.Green
            };
            chart1.Series.Add(seriesY);

            System.Windows.Forms.DataVisualization.Charting.Series seriesZ = new System.Windows.Forms.DataVisualization.Charting.Series("Z")
            {
                ChartType = SeriesChartType.Line,
                XValueType = ChartValueType.DateTime,
                Color = System.Drawing.Color.Blue
            };
            chart1.Series.Add(seriesZ);

            // Adiciona e configura a legenda
            Legend legend = new Legend("Legend");
            chart1.Legends.Add(legend);

            // Configura os eixos
            chart1.ChartAreas[0].AxisX.Title = "Time";
            chart1.ChartAreas[0].AxisY.Title = "Value";
        }




        private double previousX = double.NaN; // Armazena o valor da amostra anterior para o eixo X
        private double previousY = double.NaN; // Armazena o valor da amostra anterior para o eixo Y
        private double previousZ = double.NaN; // Armazena o valor da amostra anterior para o eixo Z

        private double CalculateAmplitude(double current, ref double previous)
        {
            if (double.IsNaN(previous))
            {
                // Se não houver valor anterior, retorna 0
                previous = current;
                return 0;
            }

            // Calcula a amplitude como a diferença entre o valor atual e o valor anterior
            double amplitude = Math.Abs(current - previous);
            previous = current; // Atualiza o valor anterior
            return amplitude;
        }







        private void InitializeSerialPort(string portName)
        {
            serialPort = new SerialPort(portName, 9600, Parity.None, 8, StopBits.One);
            serialPort.DataReceived += new SerialDataReceivedEventHandler(SerialPortDataReceived);
            serialPort.Open();
        }

        private void SerialPortDataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            string data = serialPort.ReadExisting();
            dataBuffer += data; // Acumula os dados recebidos

            // Verifica se há uma linha completa (com \n ou \r\n)
            while (dataBuffer.Contains("\n"))
            {
                int newlineIndex = dataBuffer.IndexOf("\n");
                string line = dataBuffer.Substring(0, newlineIndex).Trim(); // Extrai a linha completa
                dataBuffer = dataBuffer.Substring(newlineIndex + 1); // Remove a linha processada do buffer

                if (string.IsNullOrWhiteSpace(line)) continue;

                string[] values = line.Split('\t');
                if (values.Length == 3)
                {
                    // Atualiza o TextBox com os dados recebidos
                    Invoke(new Action(() =>
                    {
                        txtData.AppendText(DateTime.Now.ToString("HH:mm:ss.fff") + " -> " + "\t"+
                                            values[0] + "\t" + values[1] + "\t" + values[2] + "\r\n");

                        // Rolagem automática do TextBox
                        txtData.SelectionStart = txtData.Text.Length;
                        txtData.ScrollToCaret();
                    }));

                    // Atualiza o gráfico com os dados recebidos
                    UpdateChart(values);

                    // Calcula e exibe a frequência média para X, Y e Z
                    double xFreq = CalculateAverageFrequency(xSamples);
                    double yFreq = CalculateAverageFrequency(ySamples);
                    double zFreq = CalculateAverageFrequency(zSamples);

                    Invoke(new Action(() =>
                    {
                        // Configura o TextBox para múltiplas linhas e exibe a frequência
                        txtFreq.Multiline = true; // Certifique-se de que Multiline está ativado
                        txtFreq.ScrollBars = ScrollBars.Vertical; // Adiciona a barra de rolagem se necessário
                        txtFreq.Text = 
                        
                        $"Frequência média (X): {xFreq:F2} Hz\r\n" +
                                       
                        $"Frequência média (Y): {yFreq:F2} Hz\r\n" +
                        
                        $"Frequência média (Z): {zFreq:F2} Hz";


                    }));
                }
                else
                {
                    // Mensagem de depuração se os dados não estiverem no formato esperado
                    Invoke(new Action(() =>
                    {
                        txtData.AppendText("Formato de dados inválido: " + line + "\r\n");
                        txtData.SelectionStart = txtData.Text.Length;
                        txtData.ScrollToCaret();
                    }));
                }
            }
        }


        private readonly object chartLock = new object();

        private void UpdateChart(string[] values)
        {
            if (double.TryParse(values[0], out double x) &&
                double.TryParse(values[1], out double y) &&
                double.TryParse(values[2], out double z))
            {
                // Atualiza os arrays de amostras
                xSamples[sampleIndex] = x;
                ySamples[sampleIndex] = y;
                zSamples[sampleIndex] = z;
                sampleIndex = (sampleIndex + 1) % xSamples.Length; // Rotaciona o índice

                // Atualiza o gráfico com os dados recebidos
                DateTime now = DateTime.Now;

                if (chart1.InvokeRequired)
                {
                    chart1.Invoke(new Action(() =>
                    {
                        // Usando Series de System.Windows.Forms.DataVisualization.Charting
                        ((ChartSeries)chart1.Series["X"]).Points.AddXY(now, x);
                        ((ChartSeries)chart1.Series["Y"]).Points.AddXY(now, y);
                        ((ChartSeries)chart1.Series["Z"]).Points.AddXY(now, z);

                        // Ajusta o intervalo do eixo X para mostrar os dados mais recentes
                        chart1.ChartAreas[0].AxisX.Minimum = now.AddSeconds(-10).ToOADate();
                        chart1.ChartAreas[0].AxisX.Maximum = now.ToOADate();

                        // Calcula e exibe a amplitude de variação para X, Y e Z
                        double xAmplitude = CalculateAmplitude(x, ref previousX);
                        double yAmplitude = CalculateAmplitude(y, ref previousY);
                        double zAmplitude = CalculateAmplitude(z, ref previousZ);

                        // Exibe a amplitude no TextBox
                        txtAmplitude.Text = $"Amplitude X: {xAmplitude:F2}\r\n" +
                                            $"Amplitude Y: {yAmplitude:F2}\r\n" +
                                            $"Amplitude Z: {zAmplitude:F2}";

                        // Atualiza o gráfico para exibir as alterações
                        chart1.Invalidate();
                    }));
                }
            }
        }








        private double CalculateAverageFrequency(double[] samples)
        {
            // Converta para números complexos (a FFT trabalha com números complexos)
            Complex[] complexSamples = samples.Select(sample => new Complex(sample, 0)).ToArray();

            // Aplique a FFT
            Fourier.Forward(complexSamples, FourierOptions.NoScaling);

            // Calcule as magnitudes (módulos) e frequências associadas
            double samplingRate = 1.0; // Frequência de amostragem em Hz (ajuste conforme necessário)
            double[] magnitudes = complexSamples.Select(c => c.Magnitude).ToArray();
            double[] frequencies = Enumerable.Range(0, magnitudes.Length)
                                              .Select(i => i * samplingRate / magnitudes.Length)
                                              .ToArray();

            // Calcule a frequência média ponderada
            double weightedSum = 0;
            double magnitudeSum = 0;

            for (int i = 0; i < magnitudes.Length; i++)
            {
                weightedSum += frequencies[i] * magnitudes[i];
                magnitudeSum += magnitudes[i];
            }

            return magnitudeSum > 0 ? weightedSum / magnitudeSum : 0;
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (serialPort != null && serialPort.IsOpen)
            {
                serialPort.Close();
            }
        }

        private void btnConnect_Click(object sender, EventArgs e)
        {
            if (comboBoxPorts.SelectedItem != null)
            {
                string selectedPort = comboBoxPorts.SelectedItem.ToString();
                InitializeSerialPort(selectedPort);
            }
            else
            {
                MessageBox.Show("Selecione uma porta serial.");
            }
        }
    }
}
