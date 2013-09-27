using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Collections;

namespace ImageConverter
{
    public partial class Form1 : Form
    {
        private Bitmap originalImage;

        public Form1()
        {
            InitializeComponent();
        }

        private void bOpenFile_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "jpg image (*.jpg)|*.jpg";

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    lSelectedImage.Text = openFileDialog1.FileName;
                    originalImage = new Bitmap(openFileDialog1.FileName);
                    pictureBox.Image = originalImage;
                    pictureBox.SizeMode = PictureBoxSizeMode.StretchImage;
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not open file! " + ex.Message);
                }
            }
        }

        private void bConvert_Click(object sender, EventArgs e)
        {
            if (originalImage == null)
            {
                MessageBox.Show("Choose a JPG file first");
                return;
            }

            pictureBox.Image = Converter.convertTo8Bit(originalImage);
            pictureBox.SizeMode = PictureBoxSizeMode.StretchImage;
        }

        private void bSaveBinary_Click(object sender, EventArgs e)
        {
            SaveFileDialog saveFileDialog1 = new SaveFileDialog();
            saveFileDialog1.Filter = "Binary file|*.bin";
            saveFileDialog1.Title = "Save Binary 8-bit Image";
            saveFileDialog1.ShowDialog();

            if (saveFileDialog1.FileName != "")
            {
                // Saves the Image via a FileStream created by the OpenFile method.
                FileStream fs = (FileStream)saveFileDialog1.OpenFile();
                Converter.saveBinaryFile(fs, originalImage);
                fs.Close();
            }
        }

        private void bMacro_Click(object sender, EventArgs e)
        {
            Bitmap[] images = new Bitmap[15];
            int index = 0;
            for (int i = 0; i < 13; i++)
            {
                images[index++] = new Bitmap(@"\\vmware-host\Shared Folders\shared\Documents\College\2012-2013\CS3710\Application\gui\effect_bar_" + i + ".jpg");
            }
            for (int i = 0; i < 2; i++)
            {
                images[index++] = new Bitmap(@"\\vmware-host\Shared Folders\shared\Documents\College\2012-2013\CS3710\Application\gui\final_bar_" + i + ".jpg");
            }

            FileStream fs = new FileStream(@"\\vmware-host\Shared Folders\shared\Documents\College\2012-2013\CS3710\Application\gui\gui.bin", FileMode.Create);
            Converter.saveBinaryFile(fs, images);
        }

        private void bOpenBinary_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "Binary file (*.bin)|*.bin";

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    lSelectedImage.Text = openFileDialog1.FileName;
                    FileStream fs = (FileStream)openFileDialog1.OpenFile();
                    pictureBox.Image = Converter.decodeBinaryFile(fs);
                    fs.Close();
                    pictureBox.SizeMode = PictureBoxSizeMode.StretchImage;
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not open file! " + ex.Message);
                }
            }
        }
    }
}
