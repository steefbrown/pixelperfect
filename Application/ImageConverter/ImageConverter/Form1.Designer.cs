namespace ImageConverter
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
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.bOpenFile = new System.Windows.Forms.Button();
            this.lSelectedImage = new System.Windows.Forms.Label();
            this.bConvert = new System.Windows.Forms.Button();
            this.pictureBox = new System.Windows.Forms.PictureBox();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.bSaveBinary = new System.Windows.Forms.Button();
            this.bMacro = new System.Windows.Forms.Button();
            this.bOpenBinary = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
            this.SuspendLayout();
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            // 
            // bOpenFile
            // 
            this.bOpenFile.Location = new System.Drawing.Point(12, 12);
            this.bOpenFile.Name = "bOpenFile";
            this.bOpenFile.Size = new System.Drawing.Size(96, 23);
            this.bOpenFile.TabIndex = 0;
            this.bOpenFile.Text = "Choose JPG";
            this.bOpenFile.UseVisualStyleBackColor = true;
            this.bOpenFile.Click += new System.EventHandler(this.bOpenFile_Click);
            // 
            // lSelectedImage
            // 
            this.lSelectedImage.AutoSize = true;
            this.lSelectedImage.Location = new System.Drawing.Point(114, 17);
            this.lSelectedImage.Name = "lSelectedImage";
            this.lSelectedImage.Size = new System.Drawing.Size(92, 13);
            this.lSelectedImage.TabIndex = 1;
            this.lSelectedImage.Text = "path/to/image.jpg";
            // 
            // bConvert
            // 
            this.bConvert.Location = new System.Drawing.Point(12, 41);
            this.bConvert.Name = "bConvert";
            this.bConvert.Size = new System.Drawing.Size(96, 23);
            this.bConvert.TabIndex = 2;
            this.bConvert.Text = "Preview 8-bit";
            this.bConvert.UseVisualStyleBackColor = true;
            this.bConvert.Click += new System.EventHandler(this.bConvert_Click);
            // 
            // pictureBox
            // 
            this.pictureBox.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.pictureBox.Location = new System.Drawing.Point(12, 70);
            this.pictureBox.Name = "pictureBox";
            this.pictureBox.Size = new System.Drawing.Size(640, 480);
            this.pictureBox.TabIndex = 3;
            this.pictureBox.TabStop = false;
            // 
            // bSaveBinary
            // 
            this.bSaveBinary.Location = new System.Drawing.Point(117, 41);
            this.bSaveBinary.Name = "bSaveBinary";
            this.bSaveBinary.Size = new System.Drawing.Size(75, 23);
            this.bSaveBinary.TabIndex = 4;
            this.bSaveBinary.Text = "Save .bin";
            this.bSaveBinary.UseVisualStyleBackColor = true;
            this.bSaveBinary.Click += new System.EventHandler(this.bSaveBinary_Click);
            // 
            // bMacro
            // 
            this.bMacro.Location = new System.Drawing.Point(198, 41);
            this.bMacro.Name = "bMacro";
            this.bMacro.Size = new System.Drawing.Size(75, 23);
            this.bMacro.TabIndex = 5;
            this.bMacro.Text = "Macro";
            this.bMacro.UseVisualStyleBackColor = true;
            this.bMacro.Click += new System.EventHandler(this.bMacro_Click);
            // 
            // bOpenBinary
            // 
            this.bOpenBinary.Location = new System.Drawing.Point(280, 41);
            this.bOpenBinary.Name = "bOpenBinary";
            this.bOpenBinary.Size = new System.Drawing.Size(75, 23);
            this.bOpenBinary.TabIndex = 6;
            this.bOpenBinary.Text = "Open .bin";
            this.bOpenBinary.UseVisualStyleBackColor = true;
            this.bOpenBinary.Click += new System.EventHandler(this.bOpenBinary_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(666, 566);
            this.Controls.Add(this.bOpenBinary);
            this.Controls.Add(this.bMacro);
            this.Controls.Add(this.bSaveBinary);
            this.Controls.Add(this.pictureBox);
            this.Controls.Add(this.bConvert);
            this.Controls.Add(this.lSelectedImage);
            this.Controls.Add(this.bOpenFile);
            this.Name = "Form1";
            this.Text = "8-bit Image Converter";
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Button bOpenFile;
        private System.Windows.Forms.Label lSelectedImage;
        private System.Windows.Forms.Button bConvert;
        private System.Windows.Forms.PictureBox pictureBox;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
        private System.Windows.Forms.Button bSaveBinary;
        private System.Windows.Forms.Button bMacro;
        private System.Windows.Forms.Button bOpenBinary;
    }
}

