using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading.Tasks;
using System.Collections;

namespace Assembler
{
    public partial class Form1 : Form
    {
        private Assembler assembler;
        private ArrayList assembledLines;
        private Boolean assemblerSuccess;

        private HexInstWriter writer;

        private String asmFileName;
        private String hexFileName;
        private int fileType;

        public Form1()
        {
            InitializeComponent();

            assembler = new Assembler();
            assembler.FireAssemblyComplete += OnAssemblyComplete;
            assembler.FireError += OnError;
            assembler.FireStatusUpdate += OnStatusUpdate;

            writer = new HexInstWriter();
            writer.FireWriteComplete += OnWriteComplete;

            hexPreviewBox.AddPeer(asmPreviewBox);
            asmPreviewBox.AddPeer(hexPreviewBox);
        }

        public void OnAssemblyComplete(ArrayList _assembledLines, int _numHexInstructions, bool _success)
        {
            Action op = () =>
            {
                assemblerSuccess = _success;
                assembledLines = _assembledLines;

                StringBuilder hexSB = new StringBuilder();
                StringBuilder asmSB = new StringBuilder();

                foreach (FileLine line in assembledLines)
                {
                    hexSB.AppendLine(line.hexInst);
                    asmSB.AppendLine(line.originalInst);
                }

                hexPreviewBox.AppendText(hexSB.ToString());
                asmPreviewBox.AppendText(asmSB.ToString());

                if (assemblerSuccess)
                {
                    // force both previews to top
                    hexPreviewBox.SelectionStart = asmPreviewBox.SelectionStart = 0;
                    hexPreviewBox.ScrollToCaret();
                    asmPreviewBox.ScrollToCaret();
                    lStatus.Text = "Success! Assembled " + _numHexInstructions + " instructions from " + asmFileName;
                }
                else
                {
                    // force to bottom (where error was encountered)
                    hexPreviewBox.SelectionStart = asmPreviewBox.SelectionStart = int.MaxValue;
                    hexPreviewBox.ScrollToCaret();
                    asmPreviewBox.ScrollToCaret();
                }
            };

            Invoke(op);
        }

        public void OnError(string message)
        {
            Action op = () =>
            {
                lStatus.Text = message;
                MessageBox.Show(message);
            };

            Invoke(op);
        }

        public void OnStatusUpdate(string message)
        {
            Action op = () =>
            {
                lStatus.Text = message;
            };

            Invoke(op);
        }

        private void tsOpen_Click(object sender, EventArgs e)
        {
            hexFileName = string.Empty;

            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "cr16 assembly file (*.cr16)|*.cr16";

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    asmFileName = openFileDialog1.FileName;
                    Assemble();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not open file! " + ex.Message);
                }
            }
        }

        private void tsSave_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hexFileName))
                WriteFile();
            else
                SaveFile();
        }

        private void tsSaveAs_Click(object sender, EventArgs e)
        {
            SaveFile();
        }
        
        private void tsRebuild_Click(object sender, EventArgs e)
        {
            Assemble();
        }

        // Ask Assembler to parse asmFile
        private void Assemble()
        {
            if (string.IsNullOrEmpty(asmFileName))
            {
                MessageBox.Show("No file open!");
                return;
            }

            hexPreviewBox.Clear();
            asmPreviewBox.Clear();

            Task t = new Task(() => assembler.Build(asmFileName));
            t.Start();
        }

        private void SaveFile()
        {
            if (!assemblerSuccess)
            {
                MessageBox.Show("First open a well writen assembly file!");
                return;
            }

            SaveFileDialog saveFileDialog1 = new SaveFileDialog();
            saveFileDialog1.Filter = "dat file|*.dat|coe file|*.coe";
            saveFileDialog1.ShowDialog();

            hexFileName = saveFileDialog1.FileName;
            fileType = saveFileDialog1.FilterIndex;

            WriteFile();
        }

        private void WriteFile()
        {
            if (!string.IsNullOrEmpty(hexFileName))
            {
                Task t;
                switch (fileType)
                {
                    case 1:
                        t = new Task(() => writer.WriteDAT(hexFileName, assembledLines));
                        t.Start();
                        break;
                    case 2:
                        t = new Task(() => writer.WriteCOE(hexFileName, assembledLines));
                        t.Start();
                        break;
                }
                
            }
        }

        private void OnWriteComplete()
        {
            Action op = () =>
            {
                lStatus.Text = "Wrote to " + hexFileName;
            };

            Invoke(op);
        }
    }
}
