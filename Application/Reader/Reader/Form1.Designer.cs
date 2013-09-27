namespace Reader
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.textBox = new System.Windows.Forms.RichTextBox();
            this.serialPortLabel = new System.Windows.Forms.Label();
            this.serialPortSelect = new System.Windows.Forms.ComboBox();
            this.baudRateLabel = new System.Windows.Forms.Label();
            this.baudRateSelect = new System.Windows.Forms.ComboBox();
            this.listenButton = new System.Windows.Forms.Button();
            this.serialPort1 = new System.IO.Ports.SerialPort(this.components);
            this.sendButton = new System.Windows.Forms.Button();
            this.stopButton = new System.Windows.Forms.Button();
            this.sendDataTextBox = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // textBox
            // 
            this.textBox.Location = new System.Drawing.Point(12, 81);
            this.textBox.Name = "textBox";
            this.textBox.Size = new System.Drawing.Size(391, 299);
            this.textBox.TabIndex = 0;
            this.textBox.Text = "";
            // 
            // serialPortLabel
            // 
            this.serialPortLabel.AutoSize = true;
            this.serialPortLabel.Location = new System.Drawing.Point(12, 9);
            this.serialPortLabel.Name = "serialPortLabel";
            this.serialPortLabel.Size = new System.Drawing.Size(55, 13);
            this.serialPortLabel.TabIndex = 1;
            this.serialPortLabel.Text = "Serial Port";
            // 
            // serialPortSelect
            // 
            this.serialPortSelect.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.serialPortSelect.FormattingEnabled = true;
            this.serialPortSelect.Location = new System.Drawing.Point(12, 25);
            this.serialPortSelect.Name = "serialPortSelect";
            this.serialPortSelect.Size = new System.Drawing.Size(121, 21);
            this.serialPortSelect.TabIndex = 2;
            // 
            // baudRateLabel
            // 
            this.baudRateLabel.AutoSize = true;
            this.baudRateLabel.Location = new System.Drawing.Point(142, 9);
            this.baudRateLabel.Name = "baudRateLabel";
            this.baudRateLabel.Size = new System.Drawing.Size(58, 13);
            this.baudRateLabel.TabIndex = 3;
            this.baudRateLabel.Text = "Baud Rate";
            // 
            // baudRateSelect
            // 
            this.baudRateSelect.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.baudRateSelect.FormattingEnabled = true;
            this.baudRateSelect.Items.AddRange(new object[] {
            "110",
            "300",
            "1200",
            "2400",
            "4800",
            "9600",
            "19200",
            "38400",
            "57600",
            "115200",
            "230400",
            "460800",
            "921600"});
            this.baudRateSelect.Location = new System.Drawing.Point(142, 25);
            this.baudRateSelect.Name = "baudRateSelect";
            this.baudRateSelect.Size = new System.Drawing.Size(121, 21);
            this.baudRateSelect.TabIndex = 4;
            // 
            // listenButton
            // 
            this.listenButton.Location = new System.Drawing.Point(12, 52);
            this.listenButton.Name = "listenButton";
            this.listenButton.Size = new System.Drawing.Size(75, 23);
            this.listenButton.TabIndex = 5;
            this.listenButton.Text = "Listen!";
            this.listenButton.UseVisualStyleBackColor = true;
            this.listenButton.Click += new System.EventHandler(this.listenButton_Click);
            // 
            // sendButton
            // 
            this.sendButton.Location = new System.Drawing.Point(174, 52);
            this.sendButton.Name = "sendButton";
            this.sendButton.Size = new System.Drawing.Size(75, 23);
            this.sendButton.TabIndex = 6;
            this.sendButton.Text = "Send!";
            this.sendButton.UseVisualStyleBackColor = true;
            this.sendButton.Click += new System.EventHandler(this.sendButton_Click);
            // 
            // stopButton
            // 
            this.stopButton.Location = new System.Drawing.Point(93, 52);
            this.stopButton.Name = "stopButton";
            this.stopButton.Size = new System.Drawing.Size(75, 23);
            this.stopButton.TabIndex = 7;
            this.stopButton.Text = "Stop!";
            this.stopButton.UseVisualStyleBackColor = true;
            this.stopButton.Click += new System.EventHandler(this.stopButton_Click);
            // 
            // sendDataTextBox
            // 
            this.sendDataTextBox.Location = new System.Drawing.Point(255, 55);
            this.sendDataTextBox.Name = "sendDataTextBox";
            this.sendDataTextBox.Size = new System.Drawing.Size(100, 20);
            this.sendDataTextBox.TabIndex = 8;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(415, 392);
            this.Controls.Add(this.sendDataTextBox);
            this.Controls.Add(this.stopButton);
            this.Controls.Add(this.sendButton);
            this.Controls.Add(this.listenButton);
            this.Controls.Add(this.baudRateSelect);
            this.Controls.Add(this.baudRateLabel);
            this.Controls.Add(this.serialPortSelect);
            this.Controls.Add(this.serialPortLabel);
            this.Controls.Add(this.textBox);
            this.Name = "Form1";
            this.Text = "UART Reader - CE3710";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RichTextBox textBox;
        private System.Windows.Forms.Label serialPortLabel;
        private System.Windows.Forms.ComboBox serialPortSelect;
        private System.Windows.Forms.Label baudRateLabel;
        private System.Windows.Forms.ComboBox baudRateSelect;
        private System.Windows.Forms.Button listenButton;
        private System.IO.Ports.SerialPort serialPort1;
        private System.Windows.Forms.Button sendButton;
        private System.Windows.Forms.Button stopButton;
        private System.Windows.Forms.TextBox sendDataTextBox;
    }
}

