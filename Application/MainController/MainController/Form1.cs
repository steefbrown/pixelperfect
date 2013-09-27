using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;

namespace MainController
{
    public partial class Form1 : Form
    {
        Brain brain;
        WebCam webcam;

        public Form1()
        {
            InitializeComponent();

            string[] comPorts = SerialPort.GetPortNames();
            serialPortSelect.Items.AddRange(comPorts);
            serialPortSelect.SelectedIndex = 0;

            webcam = new WebCam();
            webcam.InitializeWebCam(ref webcamPreviewBox);

            brain = new Brain(ref serialPort1, webcam);
            brain.FireLogMessage += OnLogMessage;
            brain.FireStartWebcam += OnStartWebcam;
        }

        private void bReset_Click(object sender, EventArgs e)
        {
            webcam.Start();
            brain.Reset(serialPortSelect.SelectedItem.ToString());

            Log("Reset");
        }

        private void bFormat_Click(object sender, EventArgs e)
        {
            webcam.ResolutionSetting();
        }

        private void bOptions_Click(object sender, EventArgs e)
        {
            webcam.AdvanceSetting();
        }

        private void Log(string s)
        {
            logTextBox.AppendText(s + " (" + DateTime.Now.ToString("hh:mm:ss.fff") + ")\n");
        }

        private void OnLogMessage(string s)
        {
            Action op = () => Log(s);
            Invoke(op);
        }

        private void OnStartWebcam(bool start)
        {
            Action op = () =>
            {
                if (start)
                    webcam.Start();
                else
                    webcam.Stop();
            };

            Invoke(op);
        }

    }
}
