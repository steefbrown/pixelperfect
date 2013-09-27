using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using System.Threading.Tasks;
using System.Threading;

namespace MainController
{

    public delegate void LogMessageEventHandler(string message);
    public delegate void StartWebcamEventHandler(bool start);

    // The brain behind the operation.
    // 
    // When the fpga requests to receive an image, sends the image over serial port
    // one line (640 bytes) at a time, waiting for acknowlege signals along the way.
    // When the fpga requests to send an image, waits until the buffer holds an entire
    // 640*480 image, and then generates a JPEG.
    //
    class Brain
    {
        // events for interacting with main ui thread
        public event LogMessageEventHandler FireLogMessage;
        public event StartWebcamEventHandler FireStartWebcam;

        private SerialPort serialPort;
        private WebCam webcam;

        private enum State { Listening, SendingImage, ReceiveImage, AwaitingReset };
        private State state;

        private int imageNum = 0;
        private int A_count, C_count;
        private Boolean acknowledge;

        public Brain(ref SerialPort _serialPort, WebCam _webcam)
        {
            this.serialPort = _serialPort;
            this.webcam = _webcam;

            serialPort.BaudRate = 115200;
            serialPort.Parity = System.IO.Ports.Parity.None;
            serialPort.DataBits = 8;
            serialPort.StopBits = System.IO.Ports.StopBits.One;
            serialPort.Handshake = System.IO.Ports.Handshake.None;
            //serialPort.WriteBufferSize = 1048576;  // 1MB
            serialPort.ReadBufferSize = 2048576; // MUST be > 307200 bytes to get full image back
            serialPort.ReadTimeout = 1400;
            serialPort.WriteTimeout = 1400;
            serialPort.DataReceived += DataReceivedHandler;
        }

        public void Reset(string serialPortName)
        {
            if (serialPort.IsOpen)
            {
                serialPort.Close();
            }

            serialPort.PortName = serialPortName;
            serialPort.Open();
            A_count = 0;
            acknowledge = false;
            state = State.Listening;
        }

        // should get raised when there is data at the serial port buffer
        private void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            if (state == State.ReceiveImage)
            {
                int framesize = 640 * 480;

                //Log("receive image bytesToRead=" + serialPort.BytesToRead);
                if (serialPort.BytesToRead >= framesize)
                {
                    byte[] data = new byte[framesize];
                    serialPort.Read(data, 0, framesize);

                    state = State.AwaitingReset;

                    Task t = new Task(() => ProcessReceivedImage(data));
                    t.Start();
                }
            }
            else
            {
                byte[] data = new byte[serialPort.BytesToRead];
                serialPort.Read(data, 0, data.Length);

                foreach (byte b in data)
                {
                    if (b == 0x0A)
                        A_count++;
                    else if (b == 0x0C)
                        C_count++;
                }


                if (A_count == 10)
                {
                    A_count = 0;

                    if (state == State.Listening)
                    {
                        Task t = new Task(() => SendImage());
                        t.Start();
                    }
                    else if (state == State.SendingImage)
                    {
                        acknowledge = true;
                    }
                    else if (state == State.AwaitingReset)
                    {
                        // Prep to take another image
                        if (FireStartWebcam != null) FireStartWebcam(true);
                        state = State.Listening;
                        Log("Listening for more!");
                    }
                }
                else if (C_count == 10)
                {
                    C_count = 0;
                    state = State.ReceiveImage;
                    Log("state = ReceiveImage");
                    SendReceiveImageAck();
                }
            }
        }

        private void SendReceiveImageAck()
        {
            Log("sending receive image ack...");
            byte[] bytes = new byte[] {0x0C, 0x0C, 0x0C, 0x0C };
            serialPort.Write(bytes, 0, 4);
        }

        public void testCapture()
        {
            byte[] bytes = Converter.to8bit(webcam.getWebcamImage());
            Converter.decodeBinaryFile(bytes, "original_capture.jpg");
        }

        private void ProcessReceivedImage(byte[] data)
        {
            Log("full image received!");
            Converter.decodeBinaryFile(data, "received_image_"+ (imageNum++) +".jpg");

            serialPort.ReadExisting();

            // Prep to take another image
            if (FireStartWebcam != null) FireStartWebcam(true);
            state = State.Listening;
            Log("Listening for more!");
        }

        private void SendImage()
        {
            if (FireStartWebcam != null) FireStartWebcam(false);

            byte[] bytes = Converter.to8bit(webcam.getWebcamImage());

            int totalBytes = bytes.Count();
            int offset = 0;
            int line_number = 0;
            state = State.SendingImage;
            Log("Sending Image... (" + totalBytes + " bytes)" );

            while (offset < totalBytes)
            {
                // send a line at a time
                serialPort.Write(bytes, offset, 640);

                // wait for acknowledge from fpga
                while (!acknowledge) ;

                offset += 640;

                //Log("Bytes remaining: " + (totalBytes - offset) + " Line: " + line_number);
                line_number++;

                acknowledge = false;
            }

            state = State.AwaitingReset;
            Log("Image sent!");
        }

        private void Log(string s)
        {
            if (FireLogMessage != null)
                FireLogMessage(s);
        }
    }
}
