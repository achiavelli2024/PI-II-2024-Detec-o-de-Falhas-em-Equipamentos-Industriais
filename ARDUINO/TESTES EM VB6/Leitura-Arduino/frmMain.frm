VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSComm32.Ocx"
Object = "{65E121D4-0C60-11D2-A9FC-0000F8754DA1}#2.0#0"; "mschrt20.ocx"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   6870
   ClientLeft      =   60
   ClientTop       =   405
   ClientWidth     =   12345
   LinkTopic       =   "Form1"
   ScaleHeight     =   6870
   ScaleWidth      =   12345
   StartUpPosition =   3  'Windows Default
   Begin MSChart20Lib.MSChart MSChart1 
      Height          =   4815
      Left            =   120
      OleObjectBlob   =   "frmMain.frx":0000
      TabIndex        =   1
      Top             =   1920
      Width           =   11895
   End
   Begin VB.TextBox txtData 
      Height          =   1575
      Left            =   3840
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   4335
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   0
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
   ' Configura a porta serial
    MSComm1.CommPort = 8 ' Defina a porta correta (COM1, COM2, etc.)
    MSComm1.Settings = "9600,N,8,1" ' Configura a velocidade de comunicação serial
    MSComm1.InputLen = 0 ' Receber todos os dados disponíveis
    MSComm1.PortOpen = True ' Abre a porta
    MSComm1.RThreshold = 1 ' Ativa o evento OnComm quando dados são recebidos
    
    ' Configura o MSChart
    MSChart1.chartType = VtChChartType2dLine ' Define o tipo de gráfico como linha
    MSChart1.RowCount = 1 ' Número de linhas (uma linha para cada série)
    MSChart1.ColumnCount = 3 ' Número de colunas (uma para cada série: X, Y, Z)
    
    ' Inicializa as séries
    InitializeChartSeries
    
    ' Configura o título e legendas
    'MSChart1.Title.Caption = "Gráfico de Dados do Sensor"
    'MSChart1.Legend.Visible = True
    
     MSChart1.Legend = True
     
    
    MSChart1.Title.Text = "Gráfico de Dados do Sensor"
    
    
    ' Configura os eixos
    'MSChart1.Plot.Axis(VtChAxisIdX).Title.Caption = "Tempo"
    MSChart1.Plot.Axis(VtChAxisIdX) = "Tempo"
    
    MSChart1.Plot.Axis(VtChAxisIdY) = "Valores"
    
    ' Configura linhas de grade
    'MSChart1.Plot.SeriesCollection = True
    'MSChart1.Plot.GridLines(VtChAxisIdY) = True
    
   
    
    
    
    
    
    
End Sub


Private Sub InitializeChartSeries()
    ' Configura as séries (Column Indexes são baseados em 1)
    MSChart1.RowCount = 1 ' Define uma linha para as séries
    MSChart1.ColumnCount = 3 ' Define três colunas para as três séries
    
    ' Inicializa a série X
    'MSChart1.Column(1).Data = "" ' Inicializa a coluna da série X
    
    MSChart1.ColumnCount 0.1 = ""
    
    
    ' Inicializa a série Y
    MSChart1.Column(2).Data = "" ' Inicializa a coluna da série Y
    
    ' Inicializa a série Z
    MSChart1.Column(3).Data = "" ' Inicializa a coluna da série Z
End Sub


Private Sub MSComm1_OnComm()
    Dim buffer As String
    Dim dataArray() As String
    Dim i As Integer
    Dim currentTime As String

    If MSComm1.CommEvent = comEvReceive Then
        ' Recebe os dados disponíveis na porta serial
        buffer = MSComm1.Input
        
        ' Divide os dados recebidos em linhas (caso haja múltiplas leituras)
        dataArray = Split(buffer, vbCrLf)
        
        ' Obtém o timestamp atual
        currentTime = Format(Time, "hh:nn:ss") & "." & Format(Timer - Int(Timer), "000")
        
        ' Processa cada linha de dados
        For i = 0 To UBound(dataArray)
            If Trim(dataArray(i)) <> "" Then
                Dim values() As String
                ' Divide os valores por tabulação (X, Y, Z)
                values = Split(dataArray(i), vbTab)
                
                ' Verifica se há 3 valores (X, Y, Z)
                If UBound(values) = 2 Then
                    ' Adiciona os dados ao TextBox no formato especificado
                    txtData.Text = txtData.Text & currentTime & " -> " & vbTab & _
                                   values(0) & vbTab & values(1) & vbTab & values(2) & vbCrLf
                                   
                    ' Rolagem automática do TextBox
                    txtData.SelStart = Len(txtData.Text)
                    txtData.SelLength = 0
                    txtData.SetFocus
                                   
                    ' Adiciona os dados ao gráfico
                    AddDataToChart Val(values(0)), Val(values(1)), Val(values(2))
                End If
            End If
        Next i
    End If
End Sub

Private Sub AddDataToChart(ByVal xData As Double, ByVal yData As Double, ByVal zData As Double)
    ' Configura o gráfico para ter três séries e exibir linhas
    MSChart1.chartType = VtChChartType2dLine
    
    ' Define o número de linhas e colunas do gráfico
    MSChart1.RowCount = MSChart1.RowCount + 1
    MSChart1.ColumnCount = 3 ' Para os três valores X, Y, Z
    
    ' Adiciona os valores de X, Y, Z às três colunas do gráfico
    MSChart1.Row = MSChart1.RowCount
    MSChart1.Data = xData  ' Valor X na primeira série
    MSChart1.Data = yData  ' Valor Y na segunda série
    MSChart1.Data = zData  ' Valor Z na terceira série
End Sub
