using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using System.Threading.Tasks;

namespace Reader
{
    public partial class Form1 : Form
    {
        private enum State { Stopped, Listening };
        private State state;

        private int bitNum;

        public Form1()
        {
            InitializeComponent();

            state = State.Stopped;

            // Attempt to find serial ports
            try
            {
                string[] comPorts = SerialPort.GetPortNames();
                serialPortSelect.Items.AddRange(comPorts);

                serialPortSelect.SelectedIndex = 0;
                baudRateSelect.SelectedItem = "115200";
                serialPort1.Parity = System.IO.Ports.Parity.None;
                serialPort1.DataBits = 8;
                serialPort1.StopBits = System.IO.Ports.StopBits.One;
                serialPort1.Handshake = System.IO.Ports.Handshake.None;
                serialPort1.WriteBufferSize = 1048576;  // 1MB
                serialPort1.ReadBufferSize = 1048576;   // 1MB
                serialPort1.ReadTimeout = 1400; // 1400ms more than enough for 1KB even at 9600 baud.
                serialPort1.WriteTimeout = 1400;
                serialPort1.DataReceived += DataReceivedHandler;
            }
            catch (Exception e)
            {
                MessageBox.Show("Could not find serial ports! " + e.Message); 
            }
        }

        private void listenButton_Click(object sender, EventArgs e)
        {
            if (serialPort1.IsOpen)
            {
                serialPort1.Close();
            }

            try
            {
                serialPort1.PortName = serialPortSelect.SelectedItem.ToString();
                serialPort1.BaudRate = Convert.ToInt32(baudRateSelect.SelectedItem.ToString());
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to configure serial port based on your selection!" + ex.Message);
            }

            serialPort1.Open();
            bitNum = 0;
            textBox.Clear();
            state = State.Listening;
        }

        private void stopButton_Click(object sender, EventArgs e)
        {
            state = State.Stopped;
        }

        private void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            if (state == State.Listening)
            {
                //totalBytesReceived += serialPort1.BytesToRead;
                if (serialPort1.BytesToRead >= 510) // this number is magic
                {
                    byte[] data = new byte[serialPort1.BytesToRead];
                    serialPort1.Read(data, 0, data.Length);

                    Task t = new Task(() => ProcessDataRecieved(data));
                    t.Start();
                }
            }
        }

        private void ProcessDataRecieved(byte[] data)
        {
            try
            {
                foreach (byte b in data)
                {
                    Action op = () => PrintToTextBox(Convert.ToString(b,2) + "\t(#" + (bitNum++) + " - " + DateTime.Now.ToString("HH:mm:ss tt") + ")\n");
                    Invoke(op);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.Message);
            }
        }

        private void PrintToTextBox(String text)
        {
            textBox.AppendText(text);
            // scroll to bottom
            textBox.SelectionStart = textBox.Text.Length;
            textBox.ScrollToCaret();
        }

        private void sendButton_Click(object sender, EventArgs e)
        {
            string writeString = sendDataTextBox.Text;
            int numOfBytes = writeString.Length / 8;
            byte[] bytes = new byte[numOfBytes];

            for(int i = 0; i < numOfBytes; ++i)
            {
                bytes[i] = Convert.ToByte(writeString.Substring(8 * i, 8), 2);
            }

            serialPort1.Write(bytes, 0, numOfBytes);
        }
    }
}
