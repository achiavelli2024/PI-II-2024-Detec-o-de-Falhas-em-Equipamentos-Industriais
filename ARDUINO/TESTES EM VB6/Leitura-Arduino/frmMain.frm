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
    MSComm1.Settings = "9600,N,8,1" ' Configura a velocidade de comunica��o serial
    MSComm1.InputLen = 0 ' Receber todos os dados dispon�veis
    MSComm1.PortOpen = True ' Abre a porta
    MSComm1.RThreshold = 1 ' Ativa o evento OnComm quando dados s�o recebidos
    
    ' Configura o MSChart
    MSChart1.chartType = VtChChartType2dLine ' Define o tipo de gr�fico como linha
    MSChart1.RowCount = 1 ' N�mero de linhas (uma linha para cada s�rie)
    MSChart1.ColumnCount = 3 ' N�mero de colunas (uma para cada s�rie: X, Y, Z)
    
    ' Inicializa as s�ries
    InitializeChartSeries
    
    ' Configura o t�tulo e legendas
    'MSChart1.Title.Caption = "Gr�fico de Dados do Sensor"
    'MSChart1.Legend.Visible = True
    
     MSChart1.Legend = True
     
    
    MSChart1.Title.Text = "Gr�fico de Dados do Sensor"
    
    
    ' Configura os eixos
    'MSChart1.Plot.Axis(VtChAxisIdX).Title.Caption = "Tempo"
    MSChart1.Plot.Axis(VtChAxisIdX) = "Tempo"
    
    MSChart1.Plot.Axis(VtChAxisIdY) = "Valores"
    
    ' Configura linhas de grade
    'MSChart1.Plot.SeriesCollection = True
    'MSChart1.Plot.GridLines(VtChAxisIdY) = True
    
   
    
    
    
    
    
    
End Sub


Private Sub InitializeChartSeries()
    ' Configura as s�ries (Column Indexes s�o baseados em 1)
    MSChart1.RowCount = 1 ' Define uma linha para as s�ries
    MSChart1.ColumnCount = 3 ' Define tr�s colunas para as tr�s s�ries
    
    ' Inicializa a s�rie X
    'MSChart1.Column(1).Data = "" ' Inicializa a coluna da s�rie X
    
    MSChart1.ColumnCount 0.1 = ""
    
    
    ' Inicializa a s�rie Y
    MSChart1.Column(2).Data = "" ' Inicializa a coluna da s�rie Y
    
    ' Inicializa a s�rie Z
    MSChart1.Column(3).Data = "" ' Inicializa a coluna da s�rie Z
End Sub


Private Sub MSComm1_OnComm()
    Dim buffer As String
    Dim dataArray() As String
    Dim i As Integer
    Dim currentTime As String

    If MSComm1.CommEvent = comEvReceive Then
        ' Recebe os dados dispon�veis na porta serial
        buffer = MSComm1.Input
        
        ' Divide os dados recebidos em linhas (caso haja m�ltiplas leituras)
        dataArray = Split(buffer, vbCrLf)
        
        ' Obt�m o timestamp atual
        currentTime = Format(Time, "hh:nn:ss") & "." & Format(Timer - Int(Timer), "000")
        
        ' Processa cada linha de dados
        For i = 0 To UBound(dataArray)
            If Trim(dataArray(i)) <> "" Then
                Dim values() As String
                ' Divide os valores por tabula��o (X, Y, Z)
                values = Split(dataArray(i), vbTab)
                
                ' Verifica se h� 3 valores (X, Y, Z)
                If UBound(values) = 2 Then
                    ' Adiciona os dados ao TextBox no formato especificado
                    txtData.Text = txtData.Text & currentTime & " -> " & vbTab & _
                                   values(0) & vbTab & values(1) & vbTab & values(2) & vbCrLf
                                   
                    ' Rolagem autom�tica do TextBox
                    txtData.SelStart = Len(txtData.Text)
                    txtData.SelLength = 0
                    txtData.SetFocus
                                   
                    ' Adiciona os dados ao gr�fico
                    AddDataToChart Val(values(0)), Val(values(1)), Val(values(2))
                End If
            End If
        Next i
    End If
End Sub

Private Sub AddDataToChart(ByVal xData As Double, ByVal yData As Double, ByVal zData As Double)
    ' Configura o gr�fico para ter tr�s s�ries e exibir linhas
    MSChart1.chartType = VtChChartType2dLine
    
    ' Define o n�mero de linhas e colunas do gr�fico
    MSChart1.RowCount = MSChart1.RowCount + 1
    MSChart1.ColumnCount = 3 ' Para os tr�s valores X, Y, Z
    
    ' Adiciona os valores de X, Y, Z �s tr�s colunas do gr�fico
    MSChart1.Row = MSChart1.RowCount
    MSChart1.Data = xData  ' Valor X na primeira s�rie
    MSChart1.Data = yData  ' Valor Y na segunda s�rie
    MSChart1.Data = zData  ' Valor Z na terceira s�rie
End Sub
