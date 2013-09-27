namespace MainController
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
            this.webcamPreviewBox = new System.Windows.Forms.PictureBox();
            this.bReset = new System.Windows.Forms.Button();
            this.bFormat = new System.Windows.Forms.Button();
            this.bOptions = new System.Windows.Forms.Button();
            this.logTextBox = new System.Windows.Forms.RichTextBox();
            this.serialPortSelect = new System.Windows.Forms.ComboBox();
            this.serialPort1 = new System.IO.Ports.SerialPort(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.webcamPreviewBox)).BeginInit();
            this.SuspendLayout();
            // 
            // webcamPreviewBox
            // 
            this.webcamPreviewBox.Location = new System.Drawing.Point(12, 12);
            this.webcamPreviewBox.Name = "webcamPreviewBox";
            this.webcamPreviewBox.Size = new System.Drawing.Size(320, 240);
            this.webcamPreviewBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.webcamPreviewBox.TabIndex = 0;
            this.webcamPreviewBox.TabStop = false;
            // 
            // bReset
            // 
            this.bReset.Location = new System.Drawing.Point(338, 12);
            this.bReset.Name = "bReset";
            this.bReset.Size = new System.Drawing.Size(75, 23);
            this.bReset.TabIndex = 1;
            this.bReset.Text = "Reset";
            this.bReset.UseVisualStyleBackColor = true;
            this.bReset.Click += new System.EventHandler(this.bReset_Click);
            // 
            // bFormat
            // 
            this.bFormat.Location = new System.Drawing.Point(12, 258);
            this.bFormat.Name = "bFormat";
            this.bFormat.Size = new System.Drawing.Size(75, 23);
            this.bFormat.TabIndex = 3;
            this.bFormat.Text = "Format";
            this.bFormat.UseVisualStyleBackColor = true;
            this.bFormat.Click += new System.EventHandler(this.bFormat_Click);
            // 
            // bOptions
            // 
            this.bOptions.Location = new System.Drawing.Point(93, 258);
            this.bOptions.Name = "bOptions";
            this.bOptions.Size = new System.Drawing.Size(75, 23);
            this.bOptions.TabIndex = 4;
            this.bOptions.Text = "Options";
            this.bOptions.UseVisualStyleBackColor = true;
            this.bOptions.Click += new System.EventHandler(this.bOptions_Click);
            // 
            // logTextBox
            // 
            this.logTextBox.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.logTextBox.Location = new System.Drawing.Point(338, 41);
            this.logTextBox.Name = "logTextBox";
            this.logTextBox.Size = new System.Drawing.Size(157, 233);
            this.logTextBox.TabIndex = 5;
            this.logTextBox.Text = "";
            // 
            // serialPortSelect
            // 
            this.serialPortSelect.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.serialPortSelect.FormattingEnabled = true;
            this.serialPortSelect.Location = new System.Drawing.Point(174, 258);
            this.serialPortSelect.Name = "serialPortSelect";
            this.serialPortSelect.Size = new System.Drawing.Size(121, 21);
            this.serialPortSelect.TabIndex = 6;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(507, 286);
            this.Controls.Add(this.serialPortSelect);
            this.Controls.Add(this.logTextBox);
            this.Controls.Add(this.bOptions);
            this.Controls.Add(this.bFormat);
            this.Controls.Add(this.bReset);
            this.Controls.Add(this.webcamPreviewBox);
            this.Name = "Form1";
            this.Text = "VmodCam";
            ((System.ComponentModel.ISupportInitialize)(this.webcamPreviewBox)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox webcamPreviewBox;
        private System.Windows.Forms.Button bReset;
        private System.Windows.Forms.Button bFormat;
        private System.Windows.Forms.Button bOptions;
        private System.Windows.Forms.RichTextBox logTextBox;
        private System.Windows.Forms.ComboBox serialPortSelect;
        private System.IO.Ports.SerialPort serialPort1;
    }
}

